function sleep_mat_batch()
% searches for mat files and associated log files, processes and copies to target directory
%

alias_name='aliases.txt';
recid='barecarbon';
delim='_';
bird_delim='&';
log_file(1).field='logfile';
log_file(1).filename='log.txt';
log_file(1).multi=0;
base_filename='sleepdata1';
par_save = @(FILE,data) save(FILE,'data');
% returns filenames to process and their associated log file

[options,dirs]=sleep_preflight;
filenames=robofinch_dir_recurse(pwd,'data_*.mat',[],[],log_file);
[log_names,~,log_id]=unique({filenames(:).logfile});

% get aliases

cur_file=mfilename('fullpath');
[cur_path,~,~]=fileparts(cur_file);

[aliases.targets,aliases.sources,aliases.date_targets,aliases.date_sources]=sleep_read_aliases(fullfile(cur_path,alias_name));

for i=1:length(log_names)

	disp([log_names{i}]);

	[log_map,map]=sleep_read_config(log_names{i});

	pause(.05);

	proc_idx=find(log_id==i);
	files_to_proc=filenames(proc_idx);

	[log_path,~,~]=fileparts(log_names{i});

	if exist(fullfile(log_path,'.convert_complete'),'file');
		continue;
	end

	for j=1:length(log_map)

		% first check for datenumbers

		if ~isempty(log_map(j).date_num) & ~isempty(aliases.date_sources)

			alias_date_idx=(log_map(j).date_num==aliases.date_sources);

			if any(alias_date_idx) & ~strcmpi(log_map(j).name,'lhp54')
				log_map(j).name=aliases.date_targets{alias_date_idx};
				continue;
			end
		end

		alias_idx=strcmpi(log_map(j).name,aliases.sources);

		if any(alias_idx)
			log_map(j).name=aliases.targets{alias_idx};
		end


	end

	for j=1:length(log_map)
		disp([log_map(j).name]);
	end

	if options.convert_dry_run
		continue;
	end

	% scan for aliases, convert dates to datenums

	load(files_to_proc(1).name,'data');
	original_start_time=data.start_time;

	parfor j=1:length(files_to_proc)

		tmp=[];
		data=[];
		data2=[];

		fprintf('Processing %s\n',files_to_proc(j).name);

		% process files with the same log id

		try
			tmp=load(files_to_proc(j).name,'data');
		catch err
			warning('Could not read file %s',files_to_proc(j).name);
			continue;
		end

		if ~isfield(tmp,'data')
			warning('Could not read data from file %s',files_to_proc(j).name);
			continue;
		end

		data=tmp.data;
		tmp=[];

		% write directly to appropriate directory

		for k=1:length(log_map)

			log_map(k).ch.idx(log_map(k).ch.ismic)
			log_map(k).ch.idx(~log_map(k).ch.ismic)

			data2.audio.labels=0;
			data2.audio.data=data.voltage(:,log_map(k).ch.idx(log_map(k).ch.ismic));
			data2.audio.fs=data.sampling_rate;
			data2.audio.t=data.time-min(data.time);
			data2.audio.names=map.names(log_map(k).ch.idx(log_map(k).ch.ismic));

			data2.adc.labels=[1:sum(~log_map(k).ch.ismic)];
			data2.adc.data=data.voltage(:,log_map(k).ch.idx(~log_map(k).ch.ismic));
			data2.adc.fs=data2.audio.fs;
			data2.adc.t=data2.audio.t;
			data2.adc.names=map.names(log_map(k).ch.idx(~log_map(k).ch.ismic));

			decimate_f=round(data2.adc.fs/options.convert_fs);
			cutoff=options.convert_anti_alias/(data2.adc.fs/2);
			[b,a]=ellip(4,.2,40,cutoff,'low');

			data2.adc.data=downsample(filtfilt(b,a,data2.adc.data),decimate_f);
			data2.adc.t=downsample(data2.adc.t,decimate_f);
			data2.adc.fs=options.convert_fs;

			decimate_f=round(data2.audio.fs/options.convert_fs_mic);
			cutoff=options.convert_anti_alias_mic/(data2.audio.fs/2);
			[b,a]=ellip(4,.2,40,cutoff,'low');

			data2.audio.data=downsample(filtfilt(b,a,data2.audio.data),decimate_f);
			data2.audio.t=downsample(data2.audio.t,decimate_f);
			data2.audio.fs=options.convert_fs_mic;

			% store all relevant info

			data2.file_datenum=data.start_time;

			data2.parameters.units=repmat({'Volts'},[1 length(log_map(k).ch.idx)]);
			data2.parameters.sensor_range=[-10 10];
			data2.parameters.input_range=[-10 10];
			data2.parameters.units_range=[-10 10];
			data2.parameters.amp_gain=options.convert_gain_factor;
			data2.parameters.gain_correct=false; % we did not yet adjust the ephys data by amp gain

			new_filename=[ base_filename delim log_map(k).name delim ...
			 datestr(datenum(data.start_time),options.file_datefmt) '.mat' ];

			% get names for each channel

			save_dir=fullfile(dirs.data_dir,log_map(k).name,...
				datestr(datenum(original_start_time),options.datefmt),'sleep');

			if ~exist(save_dir,'dir')
				mkdir(save_dir);
			end

			sleep_par_save(fullfile(save_dir,new_filename),data2);

			data2=[];

		end
	end

	%fid=fopen(fullfile(log_path,'.convert_complete'),'w');
	%fclose(fid);

end
