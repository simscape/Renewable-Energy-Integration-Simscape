%% Helper Functions
function mustHaveFields(s, fields)
    % Validate that struct s contains all specified fields
    for i = 1:length(fields)
        if ~isfield(s, fields{i})
            error('Input struct must contain field "%s".', fields{i});
        end
    end
end