%%%% analysis for Sanne (nice example from LLB22)

% build the spike model using the first sample

root_dir='/Volumes/MRJBOD/Dropbox/Backup/sleep_analysis/llb22_sleepexample';

% day 1
% use this spike model for the remaining data

%% singing data

sigma_t=3.5;

load(fullfile(root_dir,'singing_data_01','roboaggregate.mat'),'ephys');
[spikes_day{1},spikeless_day{1}]=spikoclust_sort(ephys.data(:,:,ephys.labels==14),ephys.fs,...
  'clust_check',2,'sigma_t',sigma_t,'freq_range',[700]);
spikes_day{1}.parameters.raw_data_sz=size(ephys.data);
clear ephys;

load(fullfile(root_dir,'singing_data_02','roboaggregate.mat'),'ephys');
[spikes_day{2},spikeless_day{2}]=spikoclust_sort(ephys.data(:,1:40,ephys.labels==14),ephys.fs,...
  'clust_check',2,'sigma_t',sigma_t,'freq_range',[700],'usermodel',spikes_day{1}.model);
spikes_day_extract_length=size(ephys.data,1);
spikes_day{2}.parameters.raw_data_sz=size(ephys.data);
clear ephys;

%% silence data

silence_length=spikes_day{1}.parameters.raw_data_sz(1);
load(fullfile(root_dir,'silence_data_01','roboaggregate.mat'),'ephys');
len=length(ephys.data(:,ephys.labels==14));
ntrials=floor(len/silence_length);
sort_data=reshape(ephys.data(1:ntrials*silence_length,ephys.labels==14),silence_length,[]);

[spikes_silence{1},spikeless_silence{1}]=spikoclust_sort(sort_data,ephys.fs,...
  'clust_check',2,'sigma_t',sigma_t,'freq_range',[700],'usermodel',spikes_day{1}.model);
spikes_silence{1}.parameters.raw_data_sz=size(ephys.data);
clear ephys;

load(fullfile(root_dir,'silence_data_02','roboaggregate.mat'),'ephys');
len=length(ephys.data(:,ephys.labels==14));
ntrials=floor(len/silence_length);
sort_data=reshape(ephys.data(1:ntrials*silence_length,ephys.labels==14),silence_length,[]);

[spikes_silence{2},spikeless_silence{2}]=spikoclust_sort(sort_data(:,1:100),ephys.fs,...
  'clust_check',2,'sigma_t',sigma_t,'freq_range',[700],'usermodel',spikes_day{1}.model);
spikes_silence{2}.parameters.raw_data_sz=size(ephys.data);
clear ephys;

%% sleep data

% list all files in the sleep folder

listing=robofinch_dir_recurse(fullfile(root_dir,'sleep_data_01'),'*.mat');

for i=1:length(listing)
  disp([listing(i).name])
  load(fullfile(listing(i).name),'ephys','file_datenum');
  [spikes_night{i},spikeless_night{i}]=spikoclust_sort(ephys.data(:,:,ephys.labels==14),ephys.fs,...
    'clust_check',2,'sigma_t',sigma_t,'freq_range',[700],'usermodel',spikes_day{1}.model);
  spikes_night_datenums{i}=file_datenum;
  spikes_night{i}.parameters.raw_data_sz=size(ephys.data);
  clear ephys file_datenum;
end

save(fullfile(root_dir,'stats','sorted_spikes.mat'),'spikes*','-v7.3')
% save data
