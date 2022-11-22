table = readtable('./output/Rotate MED.csv');

rot = unique(table.xyrot);

ind = unique(table.ind);

w = zeros(length(rot),1);
nt = zeros(length(rot),1);
peak = zeros(length(rot),1);
ang = zeros(length(ind),1);

for i = 1:length(rot)
    
    auxRot = rot(i);
    
    w(i) = mean(table.w(ismember(table.xyrot,auxRot)));
    nt(i) = mean(table.nt(ismember(table.xyrot,auxRot)));
    peak(i) = mean(table.peak(ismember(table.xyrot,auxRot)));
    
end

for j = 1:length(ind)
    individuo = ind(j);
    tableInd = table(ismember(table.ind,individuo),:);
    [~,pos] = min(tableInd.w);
    a = tableInd.xyrot(pos);
    ang(j) = a;

end
