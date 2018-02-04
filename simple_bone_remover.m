function out = simple_bone_remover(fn)
    FS = 14;
    %addpath('D:/My Project-Spring 2017/stage1/stage1/00cba091fa4ad62cc3200a657aeb957e');
    %fn = '0a291d1b12b86213d813e3796f14b329.dcm';
    im_dic = dicominfo(fn);
    im1 = dicomread(im_dic);
    % Some scanners have cylindrical scanning bounds, but the output image is square. 
    % The pixels that fall outside of these bounds get the fixed value -2000. 
    % The first step is setting these values to 0, which currently corresponds to air. 
    im1(im1 == -2000) = 0; 
    
    
    HU = im1 - 1024;
    bool = (HU>= -900 & HU <= -320);
 
    bool_dilated = imdilate(bool, ones(3)); 
    lung = imfill(bool_dilated, 'holes');
    %lung = bool_dilated; 
    
    [L, nlabel] = bwlabel(lung);
    stats = regionprops(L,'Area');
    areas = [stats.Area];
    [sortedX,sortingIndices] = sort(areas,'descend');
    if length(sortedX) >= 2
        max2 = sortedX(2);
    else
        max2 = 10000;
    end
    idx = find([stats.Area] >= max2 ); % Or max(max2, 20000)??? % This focus on lungs and ignores other regions.
    BW2 = ismember(L,idx);
    out = BW2; 
    
end 



