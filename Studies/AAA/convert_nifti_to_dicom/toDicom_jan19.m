function toDicom_jan19(I,metadata,MR,timeresolution,resultsfolder)

%I image (4D) 
% metadata: template dicominfo


cd(resultsfolder)

I=mat2gray(I);

nslices=size(I,3); 
nframes=size(I,4);

% %TEMPORARY PARAMETER OVERWRITING FOR TESTING PURPOSES 
% nframes=5 %temp
% nslices=5 %temp


metadata=generalmetadata(metadata,MR) %skip this for now...


metadata.NumberOfTemporalPositions=nframes;
metadata.MRSeriesNrofDynamicScans=nframes;
metadata.NumberofSlicesMR=nslices
metadata.MRAcquisitionType='3D'


metadata.MRSeriesDynamicSeries='Y';
metadata.SeriesCommitted='Y ';
metadata.MRSeriesNrOfSlices=nslices;

%save original data from template
SliceLocation=metadata.SliceLocation;
% SliceLocation=1e3;
% ImagePositionPatient=metadata.ImagePositionPatient;
ImagePositionPatient=MR.Parameter.Scan.xyzOffcentres; %not entirely sure about these though


contenttime=metadata.ContentTime;
SeriesTime=metadata.SeriesTime;
% SpacingBetweenSlices=metadata.SpacingBetweenSlices 
SpacingBetweenSlices=MR.Parameter.Scan.AcqVoxelSize(3);  %(in mm probably) 

metadata=findscaling(I,metadata);
ctr=1;
for i =1:nslices 
    disp(['converting ',num2str(i) ,' of ',num2str(nslices)])
    for j=1:nframes
        It=I(:,:,i,j); %image to write; 
        
        %filenames
        dicomname=[num2str(ctr),'.dcm'];
        metadata.Filename=[resultsfolder,dicomname];
        metadata.InstanceNumber=ctr;

        %timecalculations 
        metadata.TemporalPositionIdentifier=j;
        metadata.AcquisitionTime=num2str(151601+(j-1)*timeresolution);
        metadata.ContentTime=num2str(151601+(j-1)*timeresolution);
        metadata.MRImageDynamicScanBeginTime=j;

        %slice positions
        metadata.ImagePlaneNumber=i;
        metadata.SliceLocation=SliceLocation+SpacingBetweenSlices.*(i-1);
        metadata.SliceNumberMR=i; % this one is new@

        metadata.MRImageOffCentreFH=SpacingBetweenSlices.*(i-1);  %if we have slices in FH direction only of course....
        metadata.ImagePositionPatient(3)=ImagePositionPatient(3)+SpacingBetweenSlices.*(i-1);
        %{
         ImageOrientationPatient is two vectors, defining the patient
         coordinate system relative to the image??
        %}
        
        metadata.ImageOrientationPatient=[1;0;0;0;1;0];
        
        dicomwrite(It, dicomname,metadata, 'ObjectType', 'MR Image Storage','CreateMode','copy','WritePrivate', true);
        ctr=ctr+1;
    end
end
end

function metadata=generalmetadata(metadata,MR)

scandate=MR.Parameter.GetValue('RFR_STUDY_DICOM_STUDY_DATE');
scantime=MR.Parameter.GetValue('RFR_SERIES_DICOM_SERIES_TIME');
metadata.StudyDate = scandate;
metadata.SeriesDate= scandate;
metadata.AcquisitionDate= scandate;
metadata.ContentDate= scandate;
metadata.StudyTime = scantime';
metadata.ContentTime = scantime
metadata.SeriesTime = scantime;

metadata.MagneticFieldStrength=3;

%use MR.Search('DICOM') to find values 


metadata.SOPClassUID=MR.Parameter.GetValue('RFR_SERIESBLOBSET_DICOM_SOP_CLASS_UID');
metadata.SOPInstanceUID=MR.Parameter.GetValue('RFR_SERIESBLOBSET_DICOM_SOP_INSTANCE_UID');
metadata.MediaStorageSOPClassUID=metadata.SOPClassUID;

metadata.MediaStorageSOPInstanceUID=metadata.SOPInstanceUID;
metadata.StudyInstanceUID=metadata.SOPInstanceUID;
% metadata.SeriesInstanceUID=metadata.SOPInstanceUID;
metadata.FrameOfReferenceUID=metadata.SOPInstanceUID;

metadata.PatientName=MR.Parameter.GetValue('RFR_STUDY_DICOM_STUDY_DESCRIPTION');
metadata.PatientAge=[];
metadata.PatientSex='';
metadata.PatientBirthDate=[];

metadata.StudyDescription=MR.Parameter.GetValue('RFR_STUDY_DICOM_STUDY_DESCRIPTION');
end



function metadata=findscaling(I,metadata);
          metadata.WindowCenter=5000;    % NO IDEA??
          metadata.WindowWidth=5000; % NO IDEA THOGUH?

          metadata.RescaleIntercept=0;
          metadata.RescaleSlope=0.5;
end



