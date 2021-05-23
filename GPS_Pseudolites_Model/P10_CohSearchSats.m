function Res = P10_CohSearchSats(inRes, isDraw, Params)
%
% ������� ������������ ������ ��������� � �����-������
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
    Search = struct( ...
        'NumSats',       [], ... % ������, ���������� ��������� ���������
        'SatNums',       [], ... % ������ 1�NumSats � �������� ���������
            ... % ���������
        'SamplesShifts', [], ... % ������ 1�NumSats, ������ ������� -
            ... % ���������� ��������, ������� ����� ���������� � �����-
            ... % ������ �� ������ ������� ������� CA-���� ����������������
            ... % ��������
        'FreqShifts',    [], ... % ������ 1�NumSats �� ���������� ���������
            ... % ������� ��������� ��������� � ��
        'CorVals',       [], ... % ������ 1�NumSats ������������ ��������
            ... % ����� �������������� ������� ������������� �� �������
            ... % ��������, �� ������� ���� ������� ��������
        'AllCorVals',    zeros(1, 32) ... % ������ ������������ ��������
            ... % ���� �������������� �������
    );

%% ��������� ����������
    % ���������� ��������, ����������� ��� �����������.
    % ��� ������������ ����������� 1 <= NumCA2Search <= 10
        NumCA2Search = 10;

    % ������ ����������� ������ ������������� ����������, ��
        CentralFreqs = -6000 : 1000/(2*NumCA2Search) : 6000;

    % ����� �����������
        SearchThreshold = Params.threshold;%10 - real world signal

%% ���������� ����������
    Search.NumCA2Search    = NumCA2Search;
    Search.CentralFreqs    = CentralFreqs;
    Search.SearchThreshold = SearchThreshold;

%% ���ר� ����������
    % ���������� ��������������� ��������� ����������
        NumCFreqs = length(CentralFreqs);

    % ����� CA-���� � ������ ������� �������������
        CALen = 1023 * Res.File.R;

%% �������� ����� �������
    % ���������� � ���������� ��������� ��
        if isDraw
            [X, Y] = meshgrid(0:CALen-1, CentralFreqs);
        end

    % ��������� ������ ��� ������ ����������
        Corr1 = zeros(NumCFreqs, CALen);
        Corr2 = zeros(NumCFreqs, CALen);

    % ��������� ���������� �� �����
        % �������� � ������
            NumOfShiftedSamples = 0;
        % ���������� ����������� ��������� ������� �� NumCA2Search
            NumOfNeededSamples = 2*NumCA2Search*CALen + (CALen-1);

    % ������� ������ ����� �����
        [Signal, ~] = ReadSignalFromFile(Res.File, ...
            NumOfShiftedSamples, NumOfNeededSamples);
        if isempty(Signal)
            return
        end

    % ���� �� ���������� ������� ���������
        % ������ ���������
            fprintf('%s ����� ���������:\n', datestr(now));
%         for k = 1:4
        k = Params.sv_id;
            % ������ ���������
                fprintf('%s     ����� �������� �%02d ...', ...
                    datestr(now), k);

            % ���������� CA-���
                CA = GenCACode(k);

            % �������� ���������
                CA = 2*CA-1;

            % �������� ������� �������������
                CA = reshape(repmat(CA, Res.File.R, 1), 1, CALen);

            % ���� �� ��������� ����������
                for n = 1 : NumCFreqs
                    % ������� ������ �� �������
                        FSignal = Signal .* ...
                            exp(1i*2*pi*(CentralFreqs(n)/Res.File.Fs)* ...
                            (0:NumOfNeededSamples-1));
                    % �������� 2*NumCA2Search �������� ��
                        Buf = conv(FSignal, fliplr(conj(CA)), 'valid');

                    % �������� ���������� ��
                        if NumCA2Search == 1
                            Corr1(n, :) = Buf(         1:CALen );
                            Corr2(n, :) = Buf(CALen + (1:CALen));
                        else
                            Tmp = NumCA2Search*CALen;
                            Corr1(n, :) = sum(reshape(Buf( ...
                                 1:Tmp ), CALen, NumCA2Search).');
                            Corr2(n, :) = sum(reshape(Buf(Tmp + ...
                                (1:Tmp)), CALen, NumCA2Search).');
                        end
                end
                
            % ������� � ������� ����������
                Corr1 = abs(Corr1);
                Corr2 = abs(Corr2);
            % ��� ��������� ������� - ����� ����� ���� �������� � �������
                % Corr1 = Corr1 .* conj(Corr1);
                % Corr2 = Corr2 .* conj(Corr2);
                
            % ������� ���������� � ������������ �����
                if max(max(Corr1)) > max(max(Corr2))
                    Corr = Corr1;
                else
                    Corr = Corr2;
                end

            % ���������� ��� �������������
%                 if isDraw > 0
%                     figure;
%                     surf(X, Y, Corr/mean(mean(Corr)));
%                     xlim([0, CALen-1]);
%                     ylim([min(CentralFreqs), max(CentralFreqs)]);
%                     xlabel('����� �� ������ CA-����, �������');
%                     ylabel('��������� �����, ��');
%                     title(sprintf(['������ �������������� �������\n', ...
%                         '������������� �� ������� ��������\n��� ', ...
%                         '�������� �%d'], k));
%                     drawnow;
%                     if isDraw > 1
%                         savefig(sprintf('SearchCoh%02d', k));
%                         if isDraw > 2
%                             close(gcf);
%                         end
%                     end
%                 end

            % ����� ���� � ���������� ��� ���������
                Max  = max(max(Corr));
                Mean = mean(mean(Corr));
                Search.AllCorVals(k) = Max / Mean;
                if Search.AllCorVals(k) >= SearchThreshold
                    % ������ ���������
                        fprintf(' ������;\n');

                    % ����������� ��������� ��������� (R, C) ������� Corr
                        [Vals, RPoses] = max(Corr);
                        [~, C] = max(Vals);
                        R = RPoses(C);

                    % ������� ������� ���� �� �������� ����� ��������������
                    % �������
                        % C = C + NumCA2Search*CALen;
                        
                    % ���������� �����������
                        Search.SatNums       = [Search.SatNums, k];
                        Search.SamplesShifts = [Search.SamplesShifts ...
                            C - 1];
                        Search.FreqShifts    = [Search.FreqShifts, ...
                            CentralFreqs(R)];
                        Search.CorVals       = [Search.CorVals, Max/Mean];
                else
                    % ������ ���������
                        fprintf(' �� ������;\n');
                end
        

    % ���������� �������� ����� �� ���� ���������
        if isDraw > 0
            figure;
            plot(Search.AllCorVals, '.-b');
            grid on;
            hold on;
            plot(Search.SatNums, Search.AllCorVals(Search.SatNums), ...
                '.r', 'MarkerSize', 24);
            plot([1, 32], [1, 1]*SearchThreshold, 'k');
            xlim([1, 32]);
            xlabel('����� CA-����');
            ylabel('�������� ������������� ��');
            legend('��� ��������', '��������, ����������� �����', '�����');
            drawnow;
            if isDraw > 1
                savefig(sprintf('FoundCoh%02d', k));
                if isDraw > 2
                    close(gcf);
                end
            end
        end
        
    % ���������� ����������� �� ������ ����������
        % ����������� ������� ��������� ��� ����������
            [~, I] = sort(Search.CorVals, 'descend');
        % ���� ����������
            Search.SatNums       = Search.SatNums(I);
            Search.SamplesShifts = Search.SamplesShifts(I);
            Search.FreqShifts    = Search.FreqShifts(I);
            Search.CorVals       = Search.CorVals(I);

    % �������� ���������� ��������� ���������
        Search.NumSats = length(Search.SatNums);

    % ������� ����� ���� � ������������ � Res
        Res.Search = Search;

    % ������ ���������
        fprintf(['%s     ������ ��������� ��������� � ������� ', ...
            '�������� �������� �������:\n'], datestr(now));
        Buf = sprintf('% d', Search.SatNums);
        fprintf('%s     [%s]\n', datestr(now), Buf(2:end));
        fprintf('%s     ���������.\n', datestr(now));