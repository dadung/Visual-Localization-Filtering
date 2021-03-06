function [loc, rot] = poseFromPlaceHypotheses(info, sequence)
%POSEFROMPLACEHYPOTHESES estimates 6-DoF poses from meanshift
%clustering w.r.t 3D location from place hypotheses

    if ~exist('sequence', 'var')
        sequence = 'XYZ';
    end
    %% Store location and orientation of retrieved images to matrices
    ret_loc = zeros(length(info), 3);
    ret_quat = zeros(length(info), 4);
    
    for ii = 1 : length(info)
        ret_loc(ii, :) = info{ii}.loc;
        ret_quat(ii, :) = info{ii}.rot;   
    end
    
    %% Do clustering
    [IDX,M] = meanShift(ret_loc, 5);
    
    %% Find biggest cluster
    selected_cluster = -1;
    biggest_cluster = -1;
    num_cluster = size(M, 1);
    for cidx = 1 : num_cluster
        cluster_size = length(find(IDX == cidx));
        if cluster_size > biggest_cluster
            biggest_cluster = cluster_size;
            selected_cluster = cidx;
        end
    end
    
    %% Calculate mean of 3D location and orientation
    member_ids = find(IDX == selected_cluster);
    member_loc = ret_loc(member_ids,:);
    member_quat = ret_quat(member_ids,:);
    
    loc = mean(member_loc, 1)'; 
    
    member_quat = quatnormalize(member_quat);
    rot = rotqrmean(member_quat');
    rot = quat2eul(rot', sequence)';
end

