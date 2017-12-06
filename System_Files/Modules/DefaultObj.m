classdef (Abstract) DefaultObj < handle
    properties (SetAccess=public,GetAccess=public)
		settings % a struct with the protocol level settings. See useSettings method.
		n_done_trials = 0;
        n_start_trials = 0;
		hit_history = [];
		choice_history = {};
		violation_history = [];
		RT_history = [];
		peh
        hit
        reward
        choice
		saveload
		RT
        stop_flag
        viol
		% subjectname
		% sessiondate
		% sessionstart
		% sessionend
		% sessid
		% All of these will go into the session manager.
		
		% These are 
	end % 
    
    methods
        function obj = protocol_init(obj)
            
        end
        function obj=useSettings(obj)
            
        end
        function obj=PreparNexrTrial(obj)
        end
        function obj=RunTrial(obj)
        end
        function obj=TrialComplete(obj)
        end
        function obj=saveTrial(obj)
            meta.hit = obj.hit;
			meta.viol = obj.viol;
			meta.reward = obj.reward;
			meta.trialnum = obj.n_done_trials;
			%meta.parsed_events = obj.peh(end);
			meta.RT = obj.RT;
            meta.sessid=obj.saveload.sessid;
            meta.subjid=obj.saveload.subjid;
            spec = obj.getProtoTrialData();
            %obj.saveload.saveTrial(meta, spec);
            if strcmp(obj.settings.protocol,'Operant')              
                insertTrialData('operant',{'trials_in_this_stage','target_port_1','target_port_2'...
                   ,'choice_port_1','choice_port_2','viol','reward','trialnum','RT','sessid',...
                    'subjid','trialtime'},{spec.trials_in_this_stage,spec.target_port_1,spec.target_port_2,...
                    spec.choice_port_1,spec.choice_port_1,meta.viol,meta.reward,meta.trialnum,meta.RT,...
                    meta.sessid,meta.subjid,spec.trialtime});
            end
        end
        function obj=saveSession(obj)
        end
        function obj=saveSettings(obj)
        end
        
    end
end