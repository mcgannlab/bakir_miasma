function [ output_frame ] = load_avg_frame_from_procv1( varargin )
%LOAD_AVG_FRAME_FROM_PROCV1 Arguments: filename, path, firstframe,
%lastframe, image_choice(1-6, 98, or 99)
%   Pass 99 as movie type to get all 6 maps, plus RLIs; Pass 98 to get
%   average of raw images over specified frame range

%PARSE THE INPUT ARGUMENTS, IF ANY
switch nargin
    case 0  %if no arguments passed, prompt for filename
        [rdfile, pathname]=uigetfile({'*procv1.mat','Preprocessed File (*procv1.mat)'}, 'Choose data file');     
        startframe_string = inputdlg('What is the first frame for the window you want to average?');
        startframe = str2num(startframe_string{1});
        endframe_string = inputdlg('What is the final frame for the baseline measurement?');
        endframe = str2num(endframe_string{1});
        movie_type_string = inputdlg('Which data movie? 1=DF, 2=DF_sHP, 3=DF_sLP, 4=DFperF, 5=DFperF_sHP, 6=DFperF_sLP');
        movie_type = str2num(movie_type_string{1});

    case 5  %if full set of arguments passed, fill in the variables
        rdfile = char(varargin{1});
        pathname = char(varargin{2});
        startframe = varargin{3};
        endframe = varargin{4};
        movie_type = varargin{5};

    otherwise
        display('This function takes 5 arguments or none.');
        return
end

cd(char(pathname));
switch(movie_type)
    case 1
        load(rdfile, 'Data_3D_DF');
        Num_Rows = size(Data_3D_DF, 1);
        Num_Columns = size(Data_3D_DF, 2);     
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DF(q,p,startframe:endframe));
          end
        end
        return
    case 2
        load(rdfile, 'Data_3D_DF_sHP');
        Num_Rows = size(Data_3D_DF_sHP, 1);
        Num_Columns = size(Data_3D_DF_sHP, 2); 
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DF_sHP(q,p,startframe:endframe));
          end
        end
        return   
    case 3        
        load(rdfile, 'Data_3D_DF_sLP');
        Num_Rows = size(Data_3D_DF_sLP, 1);
        Num_Columns = size(Data_3D_DF_sLP, 2); 
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DF_sLP(q,p,startframe:endframe));
          end
        end
        return
    case 4        
        load(rdfile, 'Data_3D_DFperF');
        Num_Rows = size(Data_3D_DFperF, 1);
        Num_Columns = size(Data_3D_DFperF, 2); 
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DFperF(q,p,startframe:endframe));
          end
        end
        return
    case 5
        load(rdfile, 'Data_3D_DFperF_sHP');
        Num_Rows = size(Data_3D_DFperF_sHP, 1);
        Num_Columns = size(Data_3D_DFperF_sHP, 2); 
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DFperF_sHP(q,p,startframe:endframe));
          end
        end
        return
    case 6        
        load(rdfile, 'Data_3D_DFperF_sLP');
        Num_Rows = size(Data_3D_DFperF_sLP, 1);
        Num_Columns = size(Data_3D_DFperF_sLP, 2);        
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean(Data_3D_DFperF_sLP(q,p,startframe:endframe));
          end
        end
        return
    case 98 %allows averaging of an arbitrary number of raw images from the 2photon data
        load(rdfile, 'Data_3D');
        Num_Rows = size(Data_3D, 1);
        Num_Columns = size(Data_3D, 2);        
        output_frame = zeros(Num_Rows, Num_Columns);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p) = mean((Data_3D(q,p,startframe:endframe)));
          end
        end
        return
    case 99 %code to calculate and return all maps plus RLIs    
        %compute the DF average frame and store in the 3D matrix to return
        load(rdfile, 'Data_3D_DF');
        Num_Rows = size(Data_3D_DF, 1);
        Num_Columns = size(Data_3D_DF, 2); 
        output_frame = zeros(Num_Rows, Num_Columns, 7);
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,1) = mean(Data_3D_DF(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DF';
        %compute the DF_sHP average frame and store in the 3D matrix to return
        load(rdfile, 'Data_3D_DF_sHP');
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,2) = mean(Data_3D_DF_sHP(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DF_sHP';
        %compute the DF_sLP average frame and store in the 3D matrix to return      
        load(rdfile, 'Data_3D_DF_sLP');
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,3) = mean(Data_3D_DF_sLP(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DF_sLP';
        %compute the DFperF average frame and store in the 3D matrix to return        
        load(rdfile, 'Data_3D_DFperF');
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,4) = mean(Data_3D_DFperF(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DFperF';
        %compute the DFperF_sHP average frame and store in the 3D matrix to return        
        load(rdfile, 'Data_3D_DFperF_sHP');
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,5) = mean(Data_3D_DFperF_sHP(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DFperF_sHP';
        %compute the DFperF_sLP average frame and store in the 3D matrix to return 
        load(rdfile, 'Data_3D_DFperF_sLP');
        for q = 1:Num_Rows; %calculate average frame for specified range 
          for p = 1:Num_Columns;
             output_frame(q,p,6) = mean(Data_3D_DFperF_sLP(q,p,startframe:endframe));
          end
        end
        clear 'Data_3D_DFperF_sLP';
        %store the RLIs
        load(rdfile, 'RLI_Frame');
        output_frame(1:Num_Rows,1:Num_Columns,7) = RLI_Frame(1:Num_Rows,1:Num_Columns);
        return               
end %end of switch

clear all %probably never get here
end

