function Res = P20_CohTrackSatsAndBitSync(inRes, isDraw, Params)
%
% ������� ������������ �������� ��������� � ������� �������������
%
% ������� ����������
%   inRes - ��������� � ������������ ������, ����������� � Main;
%   isDraw - 0/1/2/3 ���� ������������� ���������� ����������� ����������
%       ������ �������.
%
% �������� ����������
%   Res - ���������, ������� ���������� �� inRes ����������� ������ ����,
%       �������� �������� ���� ���� � ����.

% �������������� �����������
    Res = inRes;

%% ������������� ����������
    Track = struct( ...
        'SamplesShifts',     {cell(Res.Search.NumSats, 1)}, ... 
        'CorVals',           {cell(Res.Search.NumSats, 1)}, ...
        'HardSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'FineSamplesShifts', {cell(Res.Search.NumSats, 1)}, ... 
        'EPLCorVals',        {cell(Res.Search.NumSats, 1)}, ...
        'DLL',               {cell(Res.Search.NumSats, 1)}, ...
        'FPLL',              {cell(Res.Search.NumSats, 1)} ...
    );
    % ������ ������ cell-�������� SamplesShifts, CorVals, HardSamplesShifts
    %   FineSamplesShifts �������� �������� 1xN, ��� N - ����������
    %   �������� CA-���� ���������������� ��������, ��������� � �����-
    %   ������ (N ����� ���� ������ ��� ������ ���������).
    % ������ ������� ������� SamplesShifts{k} - ������� ����������
    %   ��������, ������� ���� ���������� � �����-������ �� ������
    %   ���������������� ������� CA-����.
    % ������ ������� ������� CorVals{k} - ����������� �������� ����������
    %   ����� �������, ���������� ��������������� ������ CA-����, � �������
    %   ��������.
    % ������ ������� �������� HardSamplesShifts{k}, FineSamplesShifts{k} -
    %   �������������� ������� � ����� ����� �������� SamplesShifts{k}.
    % ������ ������ cell-������� EPLCorVals �������� �������� 3xN ��������
    %   Early, Promt � Late ����������. ��� ����: SamplesShifts{k} =
    %   EPLCorVals{k}(2, :).
    % DLL, FPLL - ��� ������������� ���� ���� � �������-���� �������.

    BitSync = struct( ...
        'CAShifts', zeros(Res.Search.NumSats, 1), ... 
        'Cors', zeros(Res.Search.NumSats, 20) ...
    );
    % ������ ������� ������� CAShifts - ���������� �������� CA-����,
    %   ������� ���� ���������� �� ������ ����.
    % ������ ������ ������� Cors - ����������, �� ������� �������� �������
    %   ������������ ������� �������������.

%% ��������� ����������
    % ������� ��������
        DLL.FilterOrder = 2;
        FPLL.FilterOrder = [2, 3];%[2, 3]; %[1, 2];   
        
    % � DLL � FPLL ����� ��������� ������� ������ ��� ������� �� ��� �����
    % ����������
        % ������ ��������
%             DLL.FilterBands  = [0.05; 0.05; 0.05; 0.05];
%             FPLL.FilterBands = [ ...
%                 5, 5; ...
%                 2.5, 2.5; ...
%                 1, 1; ...
%                 0.2, 0.2];

%             DLL.FilterBands  = [0.05];
%             FPLL.FilterBands = [ ...
%                 5, 5; ...
%                 5, 5; ...
%                 5, 5; ...
%                 2, 2];
            DLL.FilterBands  = [0.05];
            FPLL.FilterBands = [ ...
                    5, 5; ...
                    5, 5; ...
                    5, 5; ...
                    2, 2];
            
        % ���������� �������� ���������� ��� ����������
            DLL.NumsIntCA  = [4, 10, 20, 20];
            FPLL.NumsIntCA = [4, 10, 20, 20];

	% ��������� ���������� �������� CA-����, ����������� ��� ��������
	% ������������� �������� ����� ����������� DLL � FPLL. ��������
	% �������� �� �������� integrate and dump
        DLL.NumsCA2CheckState  = [100, 100, 100, 100];
        FPLL.NumsCA2CheckState = [100, 100, 100, 100];
        
    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        DLL.HiTr = [0.5 0.5 0.5 0.5];
        DLL.LoTr = [0.1 0.1 0.1 0.1];
        
        FPLL.HiTr = [0.5 0.5 0.5 0.5];
        FPLL.LoTr = [0.1 0.1 0.1 0.1];
        
    % ��������� �������� ��� �������� ����� �����������
    % ���� �������� > HiTr, �� ��������� � ��������� (����� ���������)
    %   ���������
    % ���� �������� < LoTr, �� ��������� � ���������� (�����
    %   ��������������)���������
        DLL.HiTr = [0.5 0.5 0.5 0.5];
        DLL.LoTr = [0.1 0.1 0.1 0.1];
        
        FPLL.HiTr = [0.5 0.5 0.5 0.5];
        FPLL.LoTr = [0.1 0.1 0.1 0.1];

    % ������, � ������� ������������ ����������� ����� ������������
    % CA-�����
        NumCA2Disp = 5*10^3;

    % ������������ ����� �������������� CA-����� (inf - �� ����� �����!)
        MaxNumCA2Process = inf; % inf;

    % ���������� ���, ������������ ��� ������� �������������
        NBits4Sync = 100;

%% ���������� ����������
    % Track.FPLL = FPLL; % �� �����, ��� ��� �� ����� ����� ������� �
    % Track.DLL = DLL;   % �����
    Track.MaxNumCA2Process = MaxNumCA2Process;

    BitSync.NBits4Sync     = NBits4Sync;

%% ���ר� ����������
    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

    % ���������� �������� CA-����, ������������ �� ���� ���
        CAPerBit = 20;

    % ������������ CA-����, ��
        TCA = 10^-3;

%% �������� ����� ������� - ������� � ������� �������������
    % ������ ���������
        fprintf('%s ������� ��������� � ������� �������������\n', ...
            datestr(now));
    for k = 1:Res.Search.NumSats
        % ������ ���������
            fprintf('%s     ��� �������� �%02d (%d �� %d) ...\n', ...
                datestr(now), Res.Search.SatNums(k), k, ...
                Res.Search.NumSats);

        % ���������� CA-���
            CA = GenCACode(Res.Search.SatNums(k));

        % �������� ���������
            CA = 2*CA-1;

        % �������� ������� �������������
            CA = reshape(repmat(CA, Res.File.R, 1), 1, CALen);

        % ������� �������� ������������� �� �������
            HardSamplesShift = Res.Search.SamplesShifts(k);
            
        % ��������, ��� �� ������ �������� Early
            if HardSamplesShift - 1 < 0
                HardSamplesShift = HardSamplesShift + CALen;
            end

        % ������� ��������� �������� ������������� �� �������
            FreqShift = Res.Search.FreqShifts(k);

        % ��������� ������������ ����� �������� CA-����, ��� ������� �����
        % ���������� �������
            MaxNumCA = ceil((Res.File.SamplesLen - HardSamplesShift) / ...
                (CALen - 1));
            
        % ������� ������ ��� ��������� ���������
            SamplesShifts     = zeros(1, MaxNumCA);
            CorVals           = zeros(1, MaxNumCA);
            HardSamplesShifts = zeros(1, MaxNumCA);
            FineSamplesShifts = zeros(1, MaxNumCA);
            EPLCorVals        = zeros(3, MaxNumCA);

        % ������������� NCO � NCOStep
            DLL.NCO     = 0;
            DLL.NCOStep = 0;
            
            FPLL.NCO     = 1;
            FPLL.NCOStep = 2*pi*FreqShift/Res.File.Fs;
            
        % ������������� ��������� ������������� DLL � FPLL
            DLL.isSync  = 0;
            FPLL.isSync = 0;

        % ������������� ������ ��������� DLL � FPLL    
            DLL.State  = 1;
            FPLL.State = 1;

        % ��������� ������� ���������� ����������
            DLL.NumIntCA  = DLL.NumsIntCA(DLL.State);
            FPLL.NumIntCA = FPLL.NumsIntCA(FPLL.State);

        % ������������� ������� CA, � ������� ��������� �������� �����
        % ���������. ��� �������� �� ��������� �� ��� ���, ���� �� �����
        % ��������� ������� �������������.
            DLL.PosCAStateChanged = 0;
            FPLL.PosCAStateChanged = 0;
            
        % ���������� �������
            DLLFilter = ClassFilter();
            DLLFilter.PrepareFilter(DLL.FilterOrder, DLL.FilterBands(...
                DLL.State, :), TCA*DLL.NumIntCA, 0, 0);

            FPLLFilter = ClassFilter();
            FPLLFilter.PrepareFilter(FPLL.FilterOrder, FPLL.FilterBands(...
                FPLL.State, :), TCA*FPLL.NumIntCA, -FreqShift*2*pi, 0);

        % ������������� ����������� ������ ��������
            DLL.Discrs    = zeros(1, MaxNumCA);
            DLL.Outputs   = zeros(1, MaxNumCA);
            DLL.VelocAccs = zeros(1, MaxNumCA);
            DLL.AccelAccs = zeros(1, MaxNumCA);
            DLL.NCOs      = zeros(1, MaxNumCA);
            DLL.NCOSteps  = zeros(1, MaxNumCA);
            DLL.States    = zeros(1, MaxNumCA);
            DLL.isSyncs   = zeros(1, MaxNumCA);
            
            FPLL.FLLDiscrs = zeros(1, MaxNumCA);
            FPLL.PLLDiscrs = zeros(1, MaxNumCA);
            FPLL.Outputs   = zeros(1, MaxNumCA);
            FPLL.VelocAccs = zeros(1, MaxNumCA);
            FPLL.AccelAccs = zeros(1, MaxNumCA);
            FPLL.NCOs      = zeros(1, MaxNumCA);
            FPLL.NCOSteps  = zeros(1, MaxNumCA);
            FPLL.States    = zeros(1, MaxNumCA);
            FPLL.isSyncs   = zeros(1, MaxNumCA);

        % �������������� ������� ������������ �������� CA-����
            CACounter = 0;

        % ������������� ��� ������� �������������
            % ������������� ����� ���������� ������� �������������
                BitSync.isDone = 0;

            % ������������� ������� ��� ���������� (����������) ��������
            % ���������� � CA-������, �� ������� ����� ��������� �������
            % �������������
                BitSync.Ps = zeros(1, CAPerBit*NBits4Sync + 1);

            % ������� ����� ���������� � BitSync.Ps ��������
                BitSync.Counter = 0;

            % �������� ������� �������������. ��� ������ ����
            % ���������������� ����, ����� �������� ����� DLL � FPLL
                BitSync.CAShift = 0;
                
            % ������������� ������� ���������� ��� ������� �������������
                BitSync.Cor = zeros(1, CAPerBit);

        % ���� ��������
            while HardSamplesShift + CALen + 1 <= Res.File.SamplesLen
                % �� ��� ���, ���� ��� ������� ������ ��� ����������
                % ��������� E, P, L

                % �������� ������� �������� NCO DLL � NCO FPDLL
                    DLL.NCOs(CACounter+1)      = DLL.NCO;
                    DLL.NCOSteps(CACounter+1)  = DLL.NCOStep;
                    FPLL.NCOs(CACounter+1)     = FPLL.NCO;
                    FPLL.NCOSteps(CACounter+1) = FPLL.NCOStep;

                % �������� ������� �������� ������ ��������� � �����
                % ���������� � �����������
                    DLL.States(CACounter+1)  = DLL.State;
                    DLL.isSyncs(CACounter+1) = DLL.isSync;
                    
                    FPLL.States(CACounter+1)  = FPLL.State;
                    FPLL.isSyncs(CACounter+1) = FPLL.isSync;

                % � ������������� �� �������
                    SamplesShifts(CACounter+1)     = HardSamplesShift + ...
                        DLL.NCO;
                    HardSamplesShifts(CACounter+1) = HardSamplesShift;
                    FineSamplesShifts(CACounter+1) = DLL.NCO;

                % ������� ����� �����, ������ ��� ���������� ��������� E,
                % P, L
                    NumOfShiftedSamples = HardSamplesShift - 1;
                    NumOfNeededSamples  = CALen + 2;
                    [Signal, ~] = ReadSignalFromFile(Res.File, ...
                        NumOfShiftedSamples, NumOfNeededSamples);
                    
                % �������� ����� �� �������
                % (������ ������ P ������ �������������� �� FPLL.NCO!)
                    Signal = Signal * FPLL.NCO .* ...
                        exp(1i*FPLL.NCOStep*(-1:CALen));
                % ���������� � �������� E, P, L
                    Cors = conv(Signal, fliplr(conj(CA)), 'valid');
                    CorVals(CACounter+1)       = Cors(2);
                    EPLCorVals(:, CACounter+1) = Cors.';

                % ���������� �������� ��� ���������� CA
                    % ������� NCO DLL � ������ FPLL
                        % �������� FPLL.NCOStep � 
                            fd = FPLL.NCOStep*CALen/(2*pi*TCA);
                        % �������� fd � Buf
                        % 1540 = 1575.42 / 1.023
                            Buf = fd * TCA * Res.File.R / 1540;
                        % ���� ����������
                            DLL.NCO = DLL.NCO + DLL.NCOStep - Buf;
                        % ��� ������ ��� ����� FPLL.NCOStep:
                            % DLL.NCO = DLL.NCO + DLL.NCOStep;

                    % ���������, �� ������� ����� �������� ����� ����������
                        HardShift = CALen + round(DLL.NCO);
                    % �������� �������� ������������� �� ��������� CA-�����
                        HardSamplesShift = HardSamplesShift + HardShift;
                    % ������� � NCO DLL ������ ������� �����
                        DLL.NCO = DLL.NCO - round(DLL.NCO);
                    % ������� NCO FPDLL
                    % (������ ������ P ������ �������������� �� FPLL.NCO!)
                        FPLL.NCO = FPLL.NCO *...
                            exp(1i*FPLL.NCOStep*HardShift);
                    
                % ������� ������������� - ������������� (���������, ������)
                    if ~BitSync.isDone
                        % ������� ������� ����������� P
                            BitSync.Counter = BitSync.Counter + 1;
                        % ������� ����� �������� P
                            BitSync.Ps(BitSync.Counter) = Cors(2);
                        % ���� ��������� ����������� ���������� �������� P,
                        % �� ����� ��������� �������������
                            if BitSync.Counter == length(BitSync.Ps)
                                % ������� �������� ��� ����� ��������� P
                                    Buf = BitSync.Ps(2:end) .* ...
                                        conj(BitSync.Ps(1:end-1));
                                % ������ ����������
                                    BitSync.Cor = abs(sum(reshape(Buf, ...
                                        CAPerBit, NBits4Sync).'));
                                % ����� ������� ����������
                                    [~, Pos] = min(BitSync.Cor);
                                % �������� ������� �������������
                                    BitSync.CAShift = mod(Pos, CAPerBit);
                                % ������� ������ ������� �������������
                                    BitSync.isDone = 1;
                                % �������� ������� �������� CA, ��� ��, ���
                                % ������� ��������� ����� ���������
                                % ��������
                                    DLL.PosCAStateChanged  = CACounter;
                                    FPLL.PosCAStateChanged = CACounter;
                                % ���������� ��� �������������
                                    if isDraw > 0
                                        SatNum = Res.Search.SatNums(k);
                                        figure;
                                        plot(BitSync.Cor, '.-');
                                        title(sprintf(['���������� ', ...
                                            ' ��� ����������� �������', ...
                                            '\n������������� ��� ', ...
                                            '�������� �%d'], SatNum));
                                        drawnow;
                                        if isDraw > 1
                                            savefig(sprintf( ...
                                                'BitSyncCoh%02d', ...
                                                SatNum));
                                            if isDraw > 2
                                                close(gcf);
                                            end
                                        end
                                    end
                            end
                    end
                
                % ����� DLL
                    % if (mod(CACounter+1, DLL.NumIntCA) == 0)
                    if (mod(CACounter+1, DLL.NumIntCA) == ...
                            mod(BitSync.CAShift, DLL.NumIntCA))
                        % ������� ������� NumIntCA ��������
                            PosesCurr = CACounter+1 + (-DLL.NumIntCA+1:0);
                            % disp('DLL');
                            % display(PosesCurr);
                        % �������� �������� �������������� DLL
                            E = abs(sum(EPLCorVals(1, PosesCurr)));
                            L = abs(sum(EPLCorVals(3, PosesCurr)));
                            DLLDiscr = 0.5 * (E - L) / (E + L);
                        % ��� ������ �������
                            [Output, VelocAcc, AccelAcc] = ...
                                DLLFilter.Step(DLLDiscr);
                        % ��������� ����� �������� ���� NCO
                            DLL.NCOStep = -Output*TCA;
                        % �������� ����������
                            for n = PosesCurr
                                DLL.Discrs(n)     = DLLDiscr;
                                DLL.Outputs(n)    = Output;
                                DLL.VelocAccs(n)  = VelocAcc;
                                DLL.AccelAccs(n)  = AccelAcc;
                            end
                    end
                    
                % ����� FPLL
                    % if (mod(CACounter+1, FPLL.NumIntCA) == 0) && ...
                    %         (CACounter+1 > FPLL.NumIntCA)
                    if (mod(CACounter+1, FPLL.NumIntCA) == ...
                            mod(BitSync.CAShift, FPLL.NumIntCA)) && ...
                            (CACounter+1 > FPLL.NumIntCA)
                        % ������� ���������� � ������� NumIntCA ��������
                            PosesPrev = CACounter+1 - FPLL.NumIntCA + ...
                                (-FPLL.NumIntCA+1:0);
                            PosesCurr = CACounter+1                 + ...
                                (-FPLL.NumIntCA+1:0);
                            % disp('FPLL');
                            % display(PosesPrev);
                            % display(PosesCurr);
                        % �������� �������� �������������� FLL
                            Buf =    sum(EPLCorVals(2, PosesCurr)) .* ...
                                conj(sum(EPLCorVals(2, PosesPrev)));
                            FLLDiscr = atan(imag(Buf)/real(Buf)) / (FPLL.NumIntCA*TCA);
                            % � �������� ����� Kaplan
                            % real(Buf) - dot
                            % imag(Buf) - cross

                        % ������������� ��� PLL
                            Buf = sum(EPLCorVals(2, PosesCurr));
                            PLLDiscr = atan(imag(Buf)/real(Buf));

                        % ��� ������ �������
                            [Output, VelocAcc, AccelAcc] = ...
                                FPLLFilter.Step(FLLDiscr, PLLDiscr);
                        % ��������� ����� �������� ���� NCO
                            FPLL.NCOStep = -Output*TCA;
                        % ����������� ��� � ������ ������������� ������ �
                        % ���������, ������� � CALen ��� ����, ��� P
                            FPLL.NCOStep = FPLL.NCOStep / CALen;
                        % �������� ����������
                            for n = PosesCurr
                                FPLL.FLLDiscrs(n) = FLLDiscr;
                                FPLL.PLLDiscrs(n) = PLLDiscr;
                                FPLL.Outputs(n)   = Output;
                                FPLL.VelocAccs(n) = VelocAcc;
                                FPLL.AccelAccs(n) = AccelAcc;
                            end

                    end

                % ��������� �������� ����� ����������� FPLL
                    if BitSync.isDone
                        DLL.NumIntCA = 20;
                    end
                
                % ��������� �������� ����� ����������� FPLL
                    if BitSync.isDone
                        NumCA2CheckState = ...
                            FPLL.NumsCA2CheckState(FPLL.State);
                        if (mod(CACounter+1, NumCA2CheckState) == ...
                                mod(FPLL.PosCAStateChanged, ...
                                NumCA2CheckState)) && ...
                                (CACounter > FPLL.PosCAStateChanged)

                            % ������ �������� �������� ��������������
                                Phases = FPLL.PLLDiscrs( ...
                                    CACounter+1 + ...
                                    (-NumCA2CheckState+1:0));
                            % ��������� �������
                                Val = sqrt(mean((Phases/pi).^2));
                            % ��������� ����� ������ ���������
                                % �� ��������� ��� ������� ��� ���������
                                    NewState = FPLL.State;
                                if Val < FPLL.LoTr(FPLL.State)
                                    if FPLL.State < length(FPLL.LoTr)
                                        NewState = FPLL.State + 1;
                                    end
                                elseif Val > FPLL.HiTr(FPLL.State)
                                    if FPLL.State > 1
                                        NewState = FPLL.State - 1;
                                    end
                                end
                            % ���� ����� ��������� ���������, �� �����
                            % �������� ��������� �������
                                if NewState ~= FPLL.State
                                    FPLL.State = NewState;
                                    FPLL.NumIntCA = ...
                                        FPLL.NumsIntCA(NewState);
                                    FPLLFilter.ChangeParams( ...
                                        FPLL.FilterBands(NewState, :), ...
                                        TCA*FPLL.NumIntCA);
                                end
                            % ���� �� �������� ������� ������ ��������
                            % ������, �� ������������� �������� ��������
                                if Val < FPLL.HiTr(FPLL.State)
                                    FPLL.isSync = 1;
                                else
                                    FPLL.isSync = 0;
%                                     FPLL.State = 1;
                                end
                        end
                    end
                            
                % ������� �������
                    CACounter = CACounter + 1;
                % ������ ���������
                    if mod(CACounter, NumCA2Disp) == 0
                        fprintf(['%s         ���������� %d �������� ', ...
                            'CA-����\n'], datestr(now), CACounter);
                    end
                    
                % �������������� ���������!
                    if CACounter >= MaxNumCA2Process
                        break
                    end
            end

        % ����������� ���������������� �������� ��������-�����������
            SamplesShifts     = SamplesShifts(1:CACounter);
            CorVals           = CorVals(1:CACounter);
            HardSamplesShifts = HardSamplesShifts(1, 1:CACounter);
            FineSamplesShifts = FineSamplesShifts(1, 1:CACounter);
            EPLCorVals        = EPLCorVals(:, 1:CACounter);

            DLL.Discrs    = DLL.Discrs(1:CACounter);
            DLL.Outputs   = DLL.Outputs(1:CACounter);
            DLL.VelocAccs = DLL.VelocAccs(1:CACounter);
            DLL.AccelAccs = DLL.AccelAccs(1:CACounter);
            DLL.NCOs      = DLL.NCOs(1:CACounter);
            DLL.NCOSteps  = DLL.NCOSteps(1:CACounter);
            DLL.States    = DLL.States(1:CACounter);
            DLL.isSyncs   = DLL.isSyncs(1:CACounter);
            
            FPLL.FLLDiscrs = FPLL.FLLDiscrs(1:CACounter);
            FPLL.PLLDiscrs = FPLL.PLLDiscrs(1:CACounter);
            FPLL.Outputs   = FPLL.Outputs(1:CACounter);
            FPLL.VelocAccs = FPLL.VelocAccs(1:CACounter);
            FPLL.AccelAccs = FPLL.AccelAccs(1:CACounter);
            FPLL.NCOs      = FPLL.NCOs(1:CACounter);
            FPLL.NCOSteps  = FPLL.NCOSteps(1:CACounter);
            FPLL.States    = FPLL.States(1:CACounter);
            FPLL.isSyncs   = FPLL.isSyncs(1:CACounter);
            
        % �������� ���������� ��� k-�� ��������
            Track.SamplesShifts{k}     = SamplesShifts;
            Track.CorVals{k}           = CorVals;
            Track.HardSamplesShifts{k} = HardSamplesShifts;
            Track.FineSamplesShifts{k} = FineSamplesShifts;
            Track.EPLCorVals{k}        = EPLCorVals;
            Track.DLL{k}               = DLL;
            Track.FPLL{k}              = FPLL;

            BitSync.CAShifts(k) = BitSync.CAShift;
            BitSync.Cors(k, :) = BitSync.Cor;
            
        % ���������� ��� �������������
            if isDraw > 0
                SatNum = Res.Search.SatNums(k);
                figure;
                    subplot(4, 1, 1);
                        Buf = abs(Track.CorVals{k});
                        plot(Buf, '.-');
                        title(sprintf(['������ ���������� � ', ...
                            '��������� CA-���� ��� �������� �%d'], ...
                            SatNum));
                        xlim([1, CACounter]);
                        ylim([0, max(Buf)]);
                        xlabel('����� ������� CA-����');
                        grid on;
                    subplot(4, 1, 2);
                        Buf = angle(Track.CorVals{k})/pi;
                        plot(Buf, '.-');                
                        title(sprintf(['���� ���������� � ��������� ', ...
                            'CA-���� ��� �������� �%d'], SatNum));
                        xlim([1, CACounter]);
                        ylim([-1, 1]);
                        xlabel('����� ������� CA-����');
                        grid on;
                    subplot(4, 1, 3);
                        A = Track.HardSamplesShifts{k};
                        A = A - A(1);
                        A = A - (0:length(A)-1)*CALen;
                        plot(A, 'b');

                        B = Track.SamplesShifts{k};
                        B = B - B(1);
                        B = B - (0:length(B)-1)*CALen;
                        hold on;
                        plot(B, 'r');

                        f = Track.FPLL{k}.VelocAccs / (2*pi);
                        f0 = 1575.42 * 10^6;
                        C = cumsum(f)*TCA*Res.File.Fs/f0;
                        C = C + (C(1) - B(1));
                        hold on;
                        plot(C, 'k');

                        legend('Hard DLL', 'Soft DLL', 'Int Dop');
                        title(sprintf(['������ ������������� ����� ', ...
                            '������������� ��� �������� �%d'], SatNum));
                        xlim([1, CACounter]);
                        ylim([min([min(A), min(B), min(C)]), ...
                            max([max(A), max(B), max(C)])]);
                        xlabel('����� ������� CA-����');
                        grid on;
                    subplot(4, 1, 4);
                        Len = min(length(B), length(C));
                        plot(B(1:Len) - C(1:Len));
                        title(sprintf(['(Soft DLL - Int Dop) ��� ', ...
                            '�������� �%d'], SatNum));
                        xlim([1, CACounter]);
                        xlabel('����� ������� CA-����');
                        grid on;
                drawnow;
                if isDraw > 1
                    savefig(sprintf('TrackCoh%02d', SatNum));
                    if isDraw > 2
                        close(gcf);
                    end
                end
                
                figure;
                    subplot(5, 1, 1);
                        DLLDiscrs = Track.DLL{k}.Discrs;
                        plot(DLLDiscrs);
                        title(sprintf('DLLDiscrs ��� �������� �%d', ...
                            SatNum));
                        % ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 2);
                        FLLDiscrs = Track.FPLL{k}.FLLDiscrs;
                        plot(FLLDiscrs*(FPLL.NumIntCA*TCA)/pi);
                        title(sprintf('FLLDiscrs ��� �������� �%d', ...
                            SatNum));
                        ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 3);
                        PLLDiscrs = Track.FPLL{k}.PLLDiscrs;
                        plot(PLLDiscrs/pi);
                        title(sprintf('PLLDiscrs ��� �������� �%d', ...
                            SatNum));
                    	ylim([-1, 1]);
                        grid on;
                    subplot(5, 1, 4);
                        VelocAccs = Track.FPLL{k}.VelocAccs;
                        plot(VelocAccs/(2*pi));
                        title(sprintf(['VelocAccs ��� �������� ', ...
                            '�%d, ��'], SatNum));
                        grid on;
                    subplot(5, 1, 5);
                        AccelAccs = Track.FPLL{k}.AccelAccs;
                        plot(AccelAccs/(2*pi));
                        title(sprintf(['AccelAccs ��� �������� ', ...
                            '�%d, ��'], SatNum));
                        grid on;
                drawnow;
                if isDraw > 1
                    savefig(sprintf('LoopsCoh%02d', SatNum));
                    if isDraw > 2
                        close(gcf);
                    end
                end
            end

        % ������ ���������
            fprintf('%s         ���������.\n', datestr(now));
    end
    % ������� ����� ���� � ������������ � Res
        Res.Track   = Track;
        Res.BitSync = BitSync;

    % ������ ���������
        fprintf('%s     ���������.\n', datestr(now));