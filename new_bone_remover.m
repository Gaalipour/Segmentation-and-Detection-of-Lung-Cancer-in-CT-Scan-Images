function out = new_bone_remover(fn)
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
    out = HU>=-1100 & HU<= -900;
    
    bool_dilated = imdilate(bool, ones(3));
    out_eroded = imerode(out, ones(3)); 
    out_eroded_opended = imopen(out_eroded, ones(3));
    out_eroded_opended = imopen(out_eroded, ones(7));
    
    %test = imfill(out_eroded_opended & bool_dilated, 'holes');
    test = bool_dilated & ~out_eroded_opended; 
    
    lung = imfill(test, 'holes');
    
    
    
    [L, nlabel] = bwlabel(lung);
    stats = regionprops(L,'Area');
    areas = [stats.Area];
    [sortedX,sortingIndices] = sort(areas,'descend');
    if length(sortedX) >= 2
        max2 = sortedX(2);
    else
        max2 = 15000;
    end
    idx = find([stats.Area] >= 20000 ); % Or max(max2, 20000)??? % This focus on lungs and ignores other regions.
    BW2 = ismember(L,idx);
    out = BW2; 
    
end 



