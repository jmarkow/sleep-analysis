%%% get spike rate template

% bin rate

bin_fs=500;
npeaks=100;
padding=.2;
spikes_fs=25e3;

% we should probably smooth...

smooth_sig=.0025;
smooth_kernel=normpdf([-smooth_sig*3:1/bin_fs:smooth_sig*3],0,smooth_sig);
smooth_kernel=smooth_kernel./sum(smooth_kernel);

% average, no more no less

pad_smps=round(spikes_fs*padding);
nsamples=spikes_day{1}.parameters.raw_data_sz(1);
ntrials=spikes_day{1}.parameters.raw_data_sz(2);
spikes_fs=spikes_day{1}.parameters.fs;

% put spikes in your standard issue binary vector

bin_vec=[pad_smps:1/bin_fs*spikes_fs:nsamples-pad_smps];
spikes_template=zeros(length(bin_vec),ntrials);

for i=1:ntrials
  spikes_template(:,i)=histc(spikes_day{1}.times{1}(spikes_day{1}.trials{1}==i),bin_vec)*bin_fs;
  spikes_template(:,i)=conv(spikes_template(:,i),smooth_kernel,'same');
end

%%
% stitch together nighttime data and find top N matches

nsamples=spikes_night{1}.parameters.raw_data_sz(1);
ntrials=spikes_night{1}.parameters.raw_data_sz(2);
bin_vec=[pad_smps:1/bin_fs*spikes_fs:nsamples-pad_smps];

spikes_target=zeros(length(bin_vec),ntrials);

for i=1:ntrials
  spikes_target(:,i)=histc(spikes_night{1}.times{1}(spikes_night{1}.trials{1}==i),bin_vec)*bin_fs;
  spikes_target(:,i)=conv(spikes_target(:,i),smooth_kernel,'same');
end

% string 'em together, like beads on a string...a correlation string

target_vec=spikes_target(:);
target_ids=[];
for i=1:ntrials
     target_ids=[target_ids;repmat(i,[length(bin_vec) 1])];
end

[r_rev]=xcorr(zscore(mean(spikes_template(end:-1:1,:),2)),zscore(target_vec));
[r,lags]=xcorr(zscore(mean(spikes_template(1:end,:),2)),zscore(target_vec));

[pks,locs]=findpeaks(r);
[~,idx]=sort(pks,'descend');
locs=abs(lags(locs(idx)));
% take top N peaks

win_size=size(spikes_template,1);
extractions=zeros(win_size,npeaks);

for i=1:npeaks
    tmp=target_vec(locs(i)+1:locs(i)+win_size);
    tmp2=target_ids(locs(i)+1:locs(i)+win_size);
    extractions(:,i)=tmp;
end
