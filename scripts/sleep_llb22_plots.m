%%

% first plot day 1 song, song-aligned raster, then average waveform

root_dir='/Volumes/MRJBOD/Dropbox/Backup/sleep_analysis/llb22_sleepexample';
load(fullfile(root_dir,'singing_data_01','roboaggregate.mat'),'audio');
load custom_colormaps;

% make sure scaling by trial number is consistent



[s,f,t]=zftftb_pretty_sonogram(audio.data(:,1),audio.fs,...
	'len',70,'overlap',69,'norm_amp',1,'filtering',700);
spike_fs=spikes_day{1}.parameters.fs;
ylimits=[.5 40.5];
for i=1:2

    ax=[];

		fig_name=['daytime_' num2str(i)];

    fig.([ fig_name '_raster'])=figure('units','centimeters','position',[10 10 5 8]);

		ax(1)=subplot(7,3,[1 2]);
    imagesc(t,f/1e3,s);
    axis xy;
    ylim([0 8]);
    colormap(fee_map);
    set(ax(1),'xtick',[]);box off;

		ax(2)=subplot(7,3,[4 5 7 8 10 11]);

    ntrials=max(spikes_day{i}.trials{1});
    spikoclust_raster(spikes_day{i}.times{1}/spike_fs,spikes_day{i}.trials{1});
    ylim([ylimits]);
		set(ax(2),'ydir','rev');
    box off;
    xlim([.2 .85]);
		axis off;

		ax(3)=subplot(7,3,3);
		plot(mean(spikes_day{i}.windows{1},2))
		h=line([0 0],[-150 -100]);
		h2=line([0 25],[-150 -150]);

		set(h,'clipping','off')
		set(h2,'clipping','off');
		set(ax(3),'clipping','off');
		axis off;

    ax(4)=subplot(7,3,[13 14 16 17 19 20]);
    spikoclust_raster(spikes_silence{i}.times{1}/spike_fs,spikes_silence{i}.trials{1});
    xlim([0 1]);
    ylim([ylimits]);
    box off;

    linkaxes(ax([1 2 4]),'x');
		xlim([.2 .85])

end


% plot night's sleep, then the analysis of similarity
