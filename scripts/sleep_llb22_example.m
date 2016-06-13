%%%% analysis for Sanne (nice example from LLB22)

% build the spike model using the first sample

root_dir='/Volumes/RUGGEDBOD/llb22_sleepexample';

% day 1
% use this spike model for the remaining data

load(fullfile(root_dir,'singing_data_01','roboaggregate.mat'),'ephys');
[spikes_day{1},spikeless_day{1}]=spikoclust_sort(ephys.data(:,:,ephys.labels==14),ephys.fs,...
  'clust_check',2,'sigma_t',4,'freq_range',[700]);
clear ephys;

load(fullfile(root_dir,'singing_data_02','roboaggregate.mat'),'ephys');
[spikes_day{2},spikeless_day{2}]=spikoclust_sort(ephys.data(:,1:40,ephys.labels==14),ephys.fs,...
  'clust_check',2,'sigma_t',4,'freq_range',[700],'usermodel',spikes_day{1}.model);
spikes_day_extract_length=size(ephys.data,1);

clear ephys;

% list all files in the sleep folder

listing=robofinch_dir_recurse(fullfile(root_dir,'sleep_data_01'),'*.mat');

for i=1:length(listing)
  disp([listing(i).name])
  load(fullfile(listing(i).name),'ephys','file_datenum');
  [spikes_night{i},spikeless_night{i}]=spikoclust_sort(ephys.data(:,:,ephys.labels==14),ephys.fs,...
    'clust_check',2,'sigma_t',4,'freq_range',[700],'usermodel',spikes_day{1}.model);
  spikes_night_datenums{i}=file_datenum;
  clear ephys file_datenum;
end
