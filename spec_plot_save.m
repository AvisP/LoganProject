function [sptemp] = spec_plot_save(data,Fs,folder_loc,filename,plot_save_all_files,plot_axes_label)

% 

[~,sp,t,f]=SmoothData(data,Fs,1);
pp=find(sp>0);
mntmp = min(min(sp(pp)));
pp=find(sp==0);
sp(pp) = mntmp;


sptemp=log(sp);sptemp = sptemp - min(min(sptemp));
sptemp = uint8(((2^8) - 1)*(sptemp./max(max(sptemp)))); % SAVE SOME MEMORY 8X less than 64 bit double

pixel_per_sptemp_column = 4;

figure('Renderer', 'painters', 'Position', [10 10 size(sptemp,2)*pixel_per_sptemp_column 256])
SPECT_HNDL=image(t,f,sptemp);set(gca,'YD','n');m=colormap('hot');
set(SPECT_HNDL,'CDataMapping','Scaled');
axis([t(1) t(end) 0 1e4]);vv=axis;
caxis(((2^8)-1)*[0.75,1]);
if ~plot_axes_label
    set(gca,'visible','off')
    set(gca,'xtick',[])
end
if plot_axes_label
    title(filename)
end
% display(strcat(folder_loc,filename))
if plot_save_all_files
    print(strcat(folder_loc,filename,'.png'),'-dpng','-r200')
end
close


end

