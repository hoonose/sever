
function writeErrs(folder, fname, epsList, errs)
    fid = fopen(sprintf('%s/%s',folder,fname),'w');
    fprintf(fid, 'eps err\n');
    for i = 1:length(epsList)
        fprintf(fid, sprintf('%f %f\n',epsList(i),errs(i)));
    end
    fclose(fid);
end
