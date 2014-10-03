function onUnload()
%ONUNLOAD Remove the src directory from the matlab path
    srcDir = [fileparts(mfilename('fullpath')) filesep 'src'];
    rmpath(srcDir);
end
