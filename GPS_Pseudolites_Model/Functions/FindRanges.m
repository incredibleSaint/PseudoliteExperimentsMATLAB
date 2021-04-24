function ranges_user_pseudol = FindRanges(pseudol_poses, user_pos)
%Ranges between pseudolites and user
ps_size = size(pseudol_poses);
ranges_user_pseudol = zeros(1, ps_size(2));
for m = 1 : ps_size(2)
    ranges_user_pseudol(m) = sqrt(sum((user_pos - ...
                                       [pseudol_poses{m}.x ...
                                        pseudol_poses{m}.y...
                                        pseudol_poses{m}.z]) .^ 2));
end
end

