function onLoad()
%ONLOAD Add the src directory to the matlab path
    srcDir = [fileparts(mfilename('fullpath')) filesep 'src'];
    addpath(srcDir, '-end');
end

