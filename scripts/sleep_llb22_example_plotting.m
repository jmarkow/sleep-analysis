%%% plotting code for the sleep analysis

dist_bins=[10:.5:35];

% put data on the same scale

norm_extractions=zscore(extractions);
norm_template=zscore(spikes_template(end:-1:1,:));

d=pdist(norm_extractions','euclidean');
Z=linkage(d,'average');
idx=cluster(Z,'maxclust',5);
clusters=unique(idx);
clustern=length(clusters);
cluster_colors=parula(clustern);
use_data=norm_extractions;
tvec=[1:size(norm_extractions,1)]./bin_fs;

fig.night_clustergram=figure();
ax=[];
ax(1)=subplot(10,1,1);
imagesc(tvec,[],norm_template');
axis off;
ax(2)=subplot(10,1,2:10);
[dend_handle,used_colors]=markostats_clustergram(use_data,Z,d,idx,'cluster_colors',cluster_colors,'data_t',tvec,'ax',ax);
linkaxes(ax,'x');

d2=pdist(norm_template','euclidean');

n_extractions=histc(d,dist_bins);
n_template=histc(d2,dist_bins);

fig.compare_histograms=figure();
ax(1)=markolab_stairplot(n_extractions./sum(n_extractions),dist_bins,'facecolor',[1 0 0],'edgecolor','k','method','p');
hold on;
ax(2)=markolab_stairplot(n_template./sum(n_template),dist_bins,'facecolor',[0 0 1],'edgecolor','k','method','p');
ylimits=ylim();
set(gca,'TickDir','out','ytick',ylimits,'TickLength',[.02 .02],'layer','top');
xlim([10 35]);
