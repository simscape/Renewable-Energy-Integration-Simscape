function Y = estimateAdmittances(scanner)
% This function performs the estimation of the admittance along the D, Q
% and DC axis. It returns the 3x3 admittance matrix at the POI.

arguments
    scanner {mustBeA(scanner, 'AdmittanceScanner')}
end

    for i = 1:3
        scanner(i) = scanner(i).runACScan(); % scan along DQ-axis
        scanner(i) = scanner(i).runDCScan(); % scan along DC-axis
    end
    
    % Construct full admittance matrix
    Y = [scanner(1).SysD(1) scanner(1).SysD(2) scanner(1).SysDCD(1);
         scanner(2).SysQ(2) scanner(2).SysQ(1) scanner(2).SysDCQ(1);
         scanner(3).SysDCac(1) scanner(3).SysDCac(2) scanner(3).SysDC(1)];
end