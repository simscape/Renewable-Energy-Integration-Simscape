windSpeedv = 5:11;
turbineRPMv = 1:20;

for ol = 1:numel(windSpeedv)

    windSpeed = windSpeedv(ol);

    for il = 1:numel(turbineRPMv)

        [ol il];

        turbineRPM = turbineRPMv(il);

        out = sim('testWT');

        power1 = reshape(out.logsout{2}.Values.Data,5001,1);
        pitch1 = out.logsout{3}.Values.Data;

        idx = find(power1 == max(power1));

        power2(ol,il) = max(power1);
        pitch2(ol,il) = pitch1(idx(end));

    end
end
