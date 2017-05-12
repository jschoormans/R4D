classdef GoldenAngle_DCE < MRecon
    properties
        %none

    end
    
    methods
        function MR = GoldenAngle_DCE( filename )
            MR=MR@MRecon(filename);
        end
        % Overload (overwrite) the existing Perform function of MRecon    
        function Perform( MR )
            %Reconstruct only standard (imaging) data
            MR.Parameter.Parameter2Read.typ = 1;                        
            % Produce k-space Data (using MRecon functions)
            disp('Reading data...')
            MR.ReadData;
            disp('Corrections...')
            MR.DcOffsetCorrection;
            MR.PDACorrection;
            MR.RandomPhaseCorrection;
            MR.MeasPhaseCorrection;
            MR.SortData;

            MR.CalculateAngles;
            MR.PhaseShift;
            MR.K2IM;
            MR.FindSenseMap
            MR.SortDCE;
            MR.GridDCE
            
            disp('SENSE unfold...')
            MR.SENSEUnfold;
            MR.ConcomitantFieldCorrection;
            disp('Combining Coils...')
            MR.CombineCoils;
            MR.Average;
            MR.GeometryCorrection;
            MR.RemoveOversampling;
            disp('Zerofilling...')
            MR.ZeroFill;
            MR.RotateImage;
            disp('Reconstruction finished')
        
        end
        
        function CalculateAngles(MR)
            disp('Calculating angles...')
            goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
            Npe=MR.Parameter.Scan.Samples(2); %number of phase-encoding lines
            
            if MR.Parameter.Parameter2Read.ky(1)==0
            angles=[0:(goldenangle)*(pi/180):(Npe-1)*(goldenangle)*(pi/180)]; %relative angles measured (first set at 0)
            else
                angleshift=(double(MR.Parameter.Parameter2Read.ky(1))*(goldenangle*(pi/180)));
                angles=[angleshift:(goldenangle)*(pi/180):(Npe-1)*(goldenangle)*(pi/180)+angleshift]; %relative angles measured (first set at 0)
            end
            
            MR.Parameter.Gridder.RadialAngles=angles';
        end
        
        function PhaseShift(MR)
            %Trajectory correction for free-breathing radial MRI
            %Buonincontrini, Sawiak, Caprenter
            disp('Phase Shift (Eddy current) correction...')
            angles=MR.Parameter.Gridder.RadialAngles(1:size(MR.Data,2))'; %only use angles for which there is data
            
            anglesrad=mod(angles,2*pi);
            cksp=floor(size(MR.Data,1)/2)+1; %how to find it generally?
            
            for nechoes=1:size(MR.Data,7)
                for nc=1:size(MR.Data,4)
                    for nz=floor(size(MR.Data,3)/2)+1;
                        fprintf('%d -',nc)
                        y=unwrap(angle(MR.Data(cksp,:,nz,nc))); %phase of center of k-space (with corrected k: find closest to zero?!?!)
                        Gx=1;Gy=1;
                        x=[ones(size(anglesrad))',Gx.*cos(anglesrad'),Gy.*sin(anglesrad')];
                        beta=inv(x'*x)*x'*y';
                        phiec=(beta(2)*cos(angles)+beta(3)*sin(angles));
                        kspcorr(:,:,:,nc,1,1,nechoes)=((MR.Data(:,:,:,nc))).*repmat(exp(-1i.*phiec),[size(MR.Data,1) 1 size(MR.Data,3)]);
                    end
                end
            end
            MR.Data=kspcorr;
        end
        
        function FindSenseMap(MR)
            [nx,ntviews,ny,nc]=size(MR.Data);
            goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
            res=MR.Parameter.Encoding.XReconRes;
            resz=round(MR.Parameter.Encoding.ZReconRes.*MR.Parameter.Encoding.KzOversampling);
            k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);   
            
            kz=linspace(MR.Parameter.Encoding.KzRange(1),MR.Parameter.Encoding.KzRange(2),ny); 
            
            coords3D=zeros(3,nx,ny*ntviews); 
            for i=1:ny
            count=1+(i-1)*ntviews:ntviews*i; %counter for radial spoke numbers 
            coords3D(1,:,count)=real((k)).*res;
            coords3D(2,:,count)=imag((k)).*res;
            coords3D(3,:,count)=ones(size(k)).*kz(i); %??
            end
            
            ksp_perm=reshape(MR.Data,[1,nx,ny*ntviews,nc]);
            
            ImGrid=bart('nufft -i -t -d50:50:24',coords3D,ksp_perm);
            ImGrid=ifftshift(ImGrid,3);
            
            ksp_lowres=bart('fft -u 7',ImGrid);
            
            ksp_zerop=padarray(ksp_lowres,[(res-50)/2 (res-50)/2 (resz-24)/2 0]); 
            disp('to do: automate resolution of sens maps')

            sensbart=(bart('ecalib -m1',(ksp_zerop)));
            
            MR.Parameter.Recon.Sensitivities=conj(sensbart);
        end

        
        function SortDCE(MR)
            
            
            goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
            nspokes= 20; 
            disp('fix nspokes ')
            
            [nx,ntviews,ny,nc]=size(MR.Data);
            k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);
            
            %%%SORTING
            kdata=squeeze(MR.Data(:,:,:,:,1)); %select kdata for slice
            nt=floor(ntviews/nspokes);              % calculate (max) number of frames
            kdatac=kdata(:,1:nt*nspokes,:,:);       % crop the data according to the number of spokes per frame
            
            
            for ii=1:nt       % sort the data into a time-series
                kdatau(:,:,:,:,1,1,1,1,1,ii)=kdatac(:,(ii-1)*nspokes+1:ii*nspokes,:,:); %kdatau now (nfe nspoke nslice nc nt)
                ku(:,:,ii)=double(k(:,(ii-1)*nspokes+1:ii*nspokes));
            end
            
            wu=getRadWeightsGA(ku);
            
             % kdatau shouldbe MR.Data
             MR.Data=kdatau;
             % trajectory should be in gridder.trajectory??
             MR.Parameter.Gridder.Kpos=ku;
             MR.Parameter.Gridder.Weights=wu;
             
             clear kdatac kdata kdatau %clear memory

        end
        
        function GridData(MR)
            [nx,ntviews,ny,nc,~,~,~,~,~,ndyn]=size(MR.Data);
            goldenangle=MR.Parameter.GetValue('`EX_ACQ_radial_golden_ang_angle');
            res=MR.Parameter.Encoding.XReconRes;
            resz=round(MR.Parameter.Encoding.ZReconRes.*MR.Parameter.Encoding.KzOversampling);
            k=buildRadTraj2D(nx,ntviews,false,true,true,[],[],[],[],goldenangle);   
            
            kz=linspace(MR.Parameter.Encoding.KzRange(1),MR.Parameter.Encoding.KzRange(2),ny); 
            
            coords3D=zeros(3,nx,ny*ntviews); 
            for i=1:ny
            count=1+(i-1)*ntviews:ntviews*i; %counter for radial spoke numbers 
            coords3D(1,:,count)=real((k)).*res;
            coords3D(2,:,count)=imag((k)).*res;
            coords3D(3,:,count)=ones(size(k)).*kz(i); %??
            end
            
            ksp_perm=reshape(MR.Data,[1,nx,ntviews*ny,nc,1,1,1,1,1,ndyn]);
            ImGrid=bart('nufft -i -t',coords3D,ksp_perm);
            MR.Data=ifftshift(ImGrid,3);
        end

    end
    
    % These functions are Hidden to the user
    methods (Static, Hidden)

    end
end