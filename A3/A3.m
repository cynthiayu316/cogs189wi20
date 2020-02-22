% Skeleton for COGS 189 A3
% 
% Please refer to this file when the Google Doc asks you to.
% Do not modify the names of variables given to you as that will cause
% issues with autograding.
%
% You will be uploading this file to Gradescope once you are done so 
% make sure everything is executable and nothing crashes before you submit
% the assignment.
%
%
VAR_NAME = 'First Last';
VAR_PID  = 'A000000';

%--------------------------------------------------------------------------
% Q1 -- What are the four classes present in this dataset?
% Change the string to your answer.
Q1_ANS = 'Enter your answer here as a string.'; % 

%--------------------------------------------------------------------------
% Q2 -- Simple "Cross-Validation"
%
% Goal: Create a 5-fold "CV" loop
Q2_data = [1, 2, 3, 4, 5];

% Create a for loop which takes Q2_data and
% prints two things every iteration:
%  1. The number of our iterator
%  2. Every other number in Q2_data
%
% Use i as your iterating variable
i = 1;

% You will find the following lines of code very useful:
disp(i)
disp(find(Q2_data ~= i))

% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE

% Output should be:
%1
%2     3     4     5
%2
%1     3     4     5
%3
%1     2     4     5
%4
%1     2     3     5
%5
%1     2     3     4

%--------------------------------------------------------------------------
% Q3 -- Using the code given in the Google Doc as a template, set Q3_Ans to
%       be the dimensionality of EEGR_train
% Please write the code rather than defining a vector of values
Q3_Ans = []; % Put your answer here

%--------------------------------------------------------------------------
% Q4 -- When k=5, how many samples are in each bin?
% Please write code for this answer rather than an integer value
Q4_Ans = [];

%--------------------------------------------------------------------------
% Q5 -- Cross Validation Indices
% Follow the instructions and use the code given to you in the Google Doc 
% to create your own for loop which sets indices into the variables
% trainIdx and valIdx

% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE
% WRITE YOUR FOR LOOP HERE

% Ollie's implementation (delete before releasing)
% Ollie's implementation (delete before releasing)
% Ollie's implementation (delete before releasing)
% Ollie's implementation (delete before releasing)
% Ollie's implementation (delete before releasing)

% Execute all functions previously requested
A3Load
[n_channel, n_time, n_sample] = size(EEGL_train{1, 1});
randIdx = randperm(n_sample);
k = 5;
bin_size = n_sample / k;
trainIdx = cell(k, 1);
valIdx = cell(k, 1);
randIdx = reshape(randIdx, k, bin_size);

% Q5 implementation
for i = 1:k
    valIdx{i} = randIdx(i, :);
    trainIdx{i} = randIdx(randIdx ~= valIdx{i})';
    % validate
    %length(unique([valIdx{i} trainIdx{i}]));
end

%--------------------------------------------------------------------------
% Main Analysis (Do Not Modify)

% Declare useful variables
[n_subjects, n_filters] = size(EEGL_train);
train_size = bin_size * (k-1);
val_size = bin_size;
accuracy = zeros(n_subjects, k);
csp_per_class = 3;

%rng(1); % set seed

% Begin nested loops
% Subject > Fold > Band
for subject = 1:n_subjects
    for fold = 1:k
        bandScore_train = zeros(train_size*2, n_filters);
        bandScore_val   = zeros(val_size*2,   n_filters);
        for band = 1:n_filters
            L_train = EEGL_train{subject, band}(:, :, trainIdx{fold});
            R_train = EEGR_train{subject, band}(:, :, trainIdx{fold});
            L_cv    = EEGL_train{subject, band}(:, :, valIdx{fold});
            R_cv    = EEGR_train{subject, band}(:, :, valIdx{fold});
            
            train_data{1} = mat_to_cell(L_train);
            train_data{2} = mat_to_cell(R_train);
            cv_data{1} = mat_to_cell(L_cv);
            cv_data{2} = mat_to_cell(R_cv);
            [csp_filter, all_coeff] = csp_analysis_quick(train_data, csp_per_class);
            
            train_CSPed = csp_filtering(train_data,csp_filter);
            train_CSPed{1} = log_norm_BP(train_CSPed{1});
            train_CSPed{2} = log_norm_BP(train_CSPed{2});
            train_CSPed{1} = squeeze(cell2mat(train_CSPed{1}))';
            train_CSPed{2} = squeeze(cell_to_mat(train_CSPed{2}))';

            cv_CSPed = csp_filtering(cv_data, csp_filter);
            cv_CSPed{1} = log_norm_BP(cv_CSPed{1});
            cv_CSPed{2} = log_norm_BP(cv_CSPed{2});
            cv_CSPed{1} = squeeze(cell_to_mat(cv_CSPed{1}))';
            cv_CSPed{2} = squeeze(cell_to_mat(cv_CSPed{2}))';

            % prepare data for LDA training
            X_train = cat(1, train_CSPed{1}, train_CSPed{2})';
            X_cv = cat(1, cv_CSPed{1}, cv_CSPed{2})';
            y_train = [ones(size(train_CSPed{1},1),1); -1*ones(size(train_CSPed{2},1),1)];
            y_cv = [ones(size(cv_CSPed{1},1),1); -1*ones(size(cv_CSPed{2},1),1)];

            % train LDA
            [train_prob, cv_prob] =  lda_train(X_train, X_cv, y_train, y_cv);

            bandScore_train(:, band) = train_prob;
            bandScore_cv(:, band) = cv_prob;
        end
        
        X_train = bandScore_train;
        y_train = [ones(n_sample*0.8,1); zeros(n_sample*0.8,1)];
        X_cv = bandScore_cv;
        y_cv = [ones(n_sample*0.2,1); zeros(n_sample*0.2,1)];
        cv_score = TA_classifier(X_train, y_train, X_cv, subject);
        accuracy(subject,fold) = sum(y_cv==round(cv_score))/(n_sample*0.2*2);
    end
end


%--------------------------------------------------------------------------
% (Extra Credit) Q6 -- Create your own classifier
% You don't even have to use LDA if you don't want to, but the main
% task is to find a better way to utilize the filter bank besides
% simply averaging their classification probabilities.
% Please do not modify the code above, but rather copy and paste it
% and modify it down below

% YOUR CODE HERE
