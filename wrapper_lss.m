%  Written by Iryna Schommartz 1.03.2022
sub_list = [];
sess_list = [];

% Get n of subs
n_subs = length(sub_list);

for c_sub = 1:n_subs
    
    % Select one subject
    which_sub = sub_list(c_sub);

    %nbr_sess = sess_list(c_sub);
    % Select nbr of session
    nbr_sess = 2;
    %sess_list(c_sub);
    
    % Loop through sessions
       for c_sess = 1:nbr_sess     
            glm_lss( which_sub, nbr_sess)
       end
            
       
end