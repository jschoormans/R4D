function P=checkGAParams(varargin)
% function to check and initialize some parameters 

if length(varargin)>1
    error('Usage: FullRecon_SoS(P) \n')
elseif length(varargin)==1
    P=varargin{1};
else
    fprintf('Warning: no settings provided.\n Continuing recon...\n');
    P=struct;
end

% check parameters folder/field
if isfield(P,'folder') && ~isfield(P,'file');
    cd(P.folder);
    fprintf('No P.file found. \n Choose raw file...\n');
    [P.file,P.folder] = uigetfile('*.raw*','Choose raw file');
end


if ~isfield(P,'folder') || ~isfield(P,'file');
    fprintf('No P.folder or P.file found. \n Choose raw file...\n');
    [P.file,P.folder] = uigetfile('*.raw*','Choose raw file');
end
if ~isfield(P,'resultsfolder')
    P.resultsfolder=[P.folder,'Results'];
end
if ~exist(P.resultsfolder);
    mkdir(P.resultsfolder); 
end
cd(P.resultsfolder)
if ~isfield(P,'filename');
    P.filename=[regexprep(P.file,'.raw',''),'R_',datestr(now,'yy_mm_dd_HH_MM')]; %think of filename
end

if ~isfield(P,'channelcompression'); %if nothing specified, do normal 3D recon
P.channelcompression=false;
end; 

if ~isfield(P,'recontype'); %if nothing specified, do normal 3D recon
P.recontype='3D'; 
end

if ~isfield(P,'zerofill'); %if nothing specified, do normal 3D recon
P.zerofill=1; 
end


if strcmp(P.recontype,'3D')
   if ~isfield(P,'type3D')
      P.type3D=1; 
   end 
end

if ~isfield(P,'sensitvitymapscalc');
    P.sensitvitymapscalc='sense';
end

% check sensitvity parameters
if isfield(P,'sensitivitymaps')
    if (P.sensitivitymaps == 1) && strcmp(P.sensitvitymapscalc,'sense')
        for dummy=1 %used for break
        if P.channelcompression==true;
           disp('Channel Compression and sensitivity maps are not compatible! Using sum of squares instead...') 
           break;
        end
        if ~isfield(P,'coil_survey')         %ask for coil_survey
            fprintf('P.coil_survey unknown. Choose coil_survey...\n')
             [P.coil_survey] = uigetfile(fullfile(P.folder,'*.raw*'),'Choose coil_survey');
        end
        if ~isfield(P,'sense_ref')
            fprintf('P.sense_ref unknown. Choose sense_ref...\n')
            [P.sense_ref] = uigetfile(fullfile(P.folder,'*.raw*'),'Choose sense_ref');
        end
        P.senseLargeOutput=0;
        end
    end
    if  P.sensitivitymaps == 1 && strcmp(P.sensitvitymapscalc,'espirit')
        if ~isfield(P,'dynamicespirit');
            if strcmp(P.recontype,'3D')
                P.dynamicespirit=false; %3D; no dynamic espirit anyway
            else
                disp('Warning: non-dynamic espirit automatically selected!')
                P.dynamicespirit=false;
            end
        end
    end
else
    P.sensitivitymaps=true;
end

if ~strcmp(P.recontype,'3D') && P.sensitivitymaps==false; 
    error('warning, sense maps needed! Change settings.')
end

if ~isfield(P,'CS')
    P.CS=struct;
end
if ~isfield(P.CS,'iter')
    P.CS.iter=250;
end
if ~isfield(P.CS,'reg')
    P.CS.reg=0.002;
end

if ~isfield(P,'oneTEtemp')
   P.oneTEtemp=false; 
end
    
if ~isfield(P,'espiritoptions')
    P.espiritoptions=struct;
end

if ~isfield(P.espiritoptions,'nmaps')
   P.espiritoptions.nmaps=1; 
end

% DCE RECONS
if strcmp(P.recontype,'DCE')
    if ~isfield(P,'DCEparams') %initialize DCE params field
        P.DCEparams=struct();
        error('five DCEparams in P.DCEparams')
    end
    if ~isfield(P.DCEparams,'nspokes')
        error('specify number of spokes used for DCE frames! in P.DCEparams.nspokes')
    elseif P.DCEparams.nspokes==[]
        error('specify number of spokes used for DCE frames! in P.DCEparams.nspokes')
    end
    if ~isfield(P.DCEparams,'nite')
        P.DCEparams.nite=8;
    end
    if ~isfield(P.DCEparams,'outeriter')
        P.DCEparams.outeriter=4;
    end
    
    if ~isfield(P.DCEparams,'Beta')
        P.DCEparams.Beta='LS'
    end
    if ~isfield(P.DCEparams,'display')
        P.DCEparams.display=1;
    end
    
    P.DCEparams.W = TV_Temp();
    
    if ~isfield(P.DCEparams,'enableTGV')
        P.DCEparams.enableTGV=0;
    end
    
    if P.DCEparams.enableTGV==1
    P.DCEparams.W2 = TV2_Temp();
    end
    
    if ~isfield(P.DCEparams,'GUI')
        P.DCEparams.GUI=false;
    end
    
    if ~isfield(P.DCEparams,'lambdafactor')
        P.DCEparams.lambdafactor=0.25;
    end

    
end

if ~isfield(P,'debug') 
    P.debug=0; %debug level 
end


if ~isfield(P,'GPU') 
    P.GPU=0; %GPU functionality 
end

if ~isfield(P,'prewhiten') 
    P.prewhiten=0; %prewhiten option
end

if ~isfield(P,'saveMR')
   % saves the MR object after readdata/corrections
   %will  be loaded the next time, when P.reload=1;
   P.saveMR=0;
end

if ~isfield(P,'reloadMR')
    %reloads the MR object and other parameters, if it exists
    P.reloadMR=0;
end

if ~isfield(P,'clearcorr')
    %clear correction (homogeneity)
    P.clearcorr=0;
end





