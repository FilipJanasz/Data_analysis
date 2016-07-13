function [file_list, fileCounter]=filter_tdms_files(directoryname,file_names) 

    % in case list of files is not given, get one
    file_list{1}=1;
    if nargin==1
        dir_info=dir(directoryname);
        file_names={dir_info.name};
    end
   
    % make a table which marks for each file if it has a certain string in
    % the name
    tdms_files=cellfun(@(x)regexp(x,'.tdms'),file_names,'UniformOutput', false);
    index_files=cellfun(@(x)regexp(x,'_index'),file_names,'UniformOutput', false);
    %count all the files
    files_amount=numel(tdms_files);

    fileCounter=0;
    %for each file, check if it has ".tdms" in the name and not "_index"
    %and if both are a yes, then store its name as a file to process
    for i=1:files_amount
        flag_tdms=isempty(tdms_files{i});
        flag_index=isempty(index_files{i});
        if ~flag_tdms && flag_index
            %increase counter
            fileCounter=fileCounter+1;
            %store names of tdms files
            file_list{fileCounter}=file_names{i};
        end
    end

%     if isempty(file_list)
%         file_list=1;
%     end
end