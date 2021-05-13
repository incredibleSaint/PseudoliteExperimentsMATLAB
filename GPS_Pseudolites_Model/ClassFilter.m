classdef ClassFilter < handle
% �������� ������ ��� loop filter ���� DLL ��� FLL-assisted PLL filter    
    properties
        % ������� ������� (DLL) ��� (FLL, PLL)
            isDLL;
        % ������� ������� [1], [2], [3] (DLL) ��� [1, 2], [2, 3] (FLL, PLL)
            Order;
        % ������ �������� DLL, FLL, PLL
            Bnd, Bnf, Bnp;
        % ��� ����������� ��������, ���
            T;
        % ������������ �������� �������� � ���������
            VelocAcc, AccelAcc;
        % ������������ �������� DLL, FLL, PLL
            CoefsDLL, CoefsFLL, CoefsPLL;
    end
    methods
        function PrepareFilter(obj, Order, Bn, T, VelocAcc, AccelAcc)
        % ������� ������������� �������
        %
        % ������� ���������
        %   Order - 1 | 2 | 3 | [1, 2] | [2, 3];
        %   Bn    - 1 ��� 2 �������� � �������, �������� >0 � ��.
        %   T     - �������� >0 � ��������.
        %   VelocAcc, AccelAcc - �������������� ���������� ���
        %       ������������� �������������
        
%         PrepareFilter(FPLL.FilterOrder, FPLL.FilterBands(...
%                 FPLL.State, :), TCA*FPLL.NumIntCA, -FreqShift*2*pi, 0);
            
            % ��������� ��� �������
                isOk = false;
                if (numel(Order) == 1) && (numel(Bn) == 1)
                    obj.isDLL = true;
                    if (Order == 1 || Order == 2 || Order == 3)
                        isOk = true;
                    end
                elseif (numel(Order) == 2) && (numel(Bn) == 2)
                    obj.isDLL = false;
                    if (isequal(Order, [1, 2]) || isequal(Order, [2, 3]))
                        isOk = true;
                    end
                end
                
                if ~isOk
                    sprintf(['������������ ������� ������� Order ', ...
                        '�/��� ������(�) ������� Bn!\n']);
                    return
                end

            % �������� ��������� ������� ������ �������
                obj.Order = Order;
                if obj.isDLL
                    obj.Bnd = Bn(1);
                else
                    obj.Bnf = Bn(1);
                    obj.Bnp = Bn(2);
                end
                obj.T = T;

            % ��������� ������������ �������� DLL, FLL � PLL
                if obj.isDLL
                    obj.CoefsDLL = CalcCoefs(Order(1), obj.Bnd);
                else
                    obj.CoefsFLL = CalcCoefs(Order(1), obj.Bnf);
                    obj.CoefsPLL = CalcCoefs(Order(2), obj.Bnp);
                end
            
            % �������������� �������� ������������� �������� � ���������
                if nargin > 4
                    obj.VelocAcc = VelocAcc;
                else
                    obj.VelocAcc = 0;
                end
                if nargin > 5
                    obj.AccelAcc = AccelAcc;
                else
                    obj.AccelAcc = 0;
                end
        end
        function ChangeParams(obj, Bn, T, VelocAcc, AccelAcc)
            % �������� ��������� ������� ������ �������
                if obj.isDLL
                    obj.Bnd = Bn(1);
                else
                    obj.Bnf = Bn(1);
                    obj.Bnp = Bn(2);
                end
                obj.T = T;

            % ��������� ������������ �������� DLL, FLL � PLL
                if obj.isDLL
                    obj.CoefsDLL = CalcCoefs(obj.Order(1), obj.Bnd);
                else
                    obj.CoefsFLL = CalcCoefs(obj.Order(1), obj.Bnf);
                    obj.CoefsPLL = CalcCoefs(obj.Order(2), obj.Bnp);
                end
            
            % �������������� �������� ������������� �������� � ���������
                if nargin > 3
                    obj.VelocAcc = VelocAcc;
                end
                if nargin > 4
                    obj.AccelAcc = AccelAcc;
                end
        end
        function [Output, VelocAcc, AccelAcc] = Step(obj, Inp1, Inp2)
        % ������� ���������� �������� ������ ���� �������
        % ������� ������������� Kaplan: page 181, fig 5.20
        %
        % ������� ���������
        %   Inp1, Inp2 - ��� isDLL = true ������������ ������ Inp1 � ���
        %       ����� �������� � ������ �������������� DLL, ��� isDLL =
        %       false �������������� Inp1 - �������� � ������
        %       �������������� FLL � Inp2 - �������� � ������
        %       �������������� PLL
        % �������� ����������
        %   Output - ��������, ������� ����� ������ �� NCO
        %   VelocAcc, AccelAcc - ������� �������� �������������

            if obj.isDLL
                PhaseErInput = Inp1;
            else
                FreqErInput  = Inp1;
                PhaseErInput = Inp2;
            end
        
            if obj.isDLL
                switch obj.Order
                    case 1
                        Output = ...
                            PhaseErInput * obj.CoefsDLL(1);
                        obj.VelocAcc = 0;
                        obj.AccelAcc = 0;
                    case 2
                        Output = ...
                            PhaseErInput * obj.CoefsDLL(1) *  obj.T * 0.5 + ...
                            PhaseErInput * obj.CoefsDLL(2) + ...
                            ...
                            obj.VelocAcc;

                        obj.VelocAcc = obj.VelocAcc + ...
                            PhaseErInput * obj.CoefsDLL(1) * obj.T;

                        obj.AccelAcc = 0;
                    case 3
                        Output = ...
                            PhaseErInput * obj.CoefsDLL(1) * (obj.T * 0.5)^2 + ...
                            PhaseErInput * obj.CoefsDLL(2) *  obj.T * 0.5 + ...
                            PhaseErInput * obj.CoefsDLL(3) + ...
                            ...
                            obj.AccelAcc * obj.T * 0.5 + ...
                            obj.VelocAcc;

                        obj.VelocAcc = obj.VelocAcc + ...
                            PhaseErInput * obj.CoefsDLL(1) * obj.T * 0.5 * obj.T + ...
                            PhaseErInput * obj.CoefsDLL(2) * obj.T + ...
                            ...
                            obj.AccelAcc *  obj.T;

                        obj.AccelAcc = obj.AccelAcc + ...
                            PhaseErInput * obj.CoefsDLL(1) *  obj.T;
                end
            else
                if isequal(obj.Order, [1, 2])
                    Output = ...
                        FreqErInput  * obj.CoefsFLL(1) *  obj.T * 0.5 + ...
                        ...
                        PhaseErInput * obj.CoefsPLL(1) *  obj.T * 0.5 + ...
                        PhaseErInput * obj.CoefsPLL(2) + ...
                        ...
                        obj.VelocAcc;

                    obj.VelocAcc = obj.VelocAcc + ...
                        FreqErInput  * obj.CoefsFLL(1) * obj.T + ...
                        PhaseErInput * obj.CoefsPLL(1) * obj.T;

                    obj.AccelAcc = 0;
                elseif isequal(obj.Order, [2, 3])
%                     Output = ...
%                         FreqErInput  * obj.CoefsFLL(2) *  obj.T * 0.5 + ...
%                         FreqErInput  * obj.CoefsFLL(1) * (obj.T * 0.5)^2 + ...
%                         ...
%                         PhaseErInput * obj.CoefsPLL(1) * (obj.T * 0.5)^2 + ...
%                         PhaseErInput * obj.CoefsPLL(2) *  obj.T * 0.5 + ...
%                         PhaseErInput * obj.CoefsPLL(3) + ...
%                         ...
%                         obj.AccelAcc * obj.T * 0.5 + ...
%                         obj.VelocAcc;
% 
%                     obj.VelocAcc = obj.VelocAcc + ...
%                         FreqErInput  * obj.CoefsFLL(2) * obj.T + ...
%                         FreqErInput  * obj.CoefsFLL(1) * obj.T * 0.5 * obj.T + ...
%                         ...
%                         PhaseErInput * obj.CoefsPLL(1) * obj.T * 0.5 * obj.T + ...
%                         PhaseErInput * obj.CoefsPLL(2) * obj.T + ...
%                         ...
%                         obj.AccelAcc *  obj.T;
% 
%                     obj.AccelAcc = obj.AccelAcc + ...
%                         FreqErInput  * obj.CoefsFLL(1) *  obj.T + ...
%                         PhaseErInput * obj.CoefsPLL(1) *  obj.T;
                    Output = ...
                        FreqErInput  * obj.CoefsFLL(2) *  obj.T * 0.5 + ...
                        FreqErInput  * obj.CoefsFLL(1) * (obj.T * 0.5)^2 +...
                        obj.AccelAcc * obj.T * 0.5 + ...
                        obj.VelocAcc;

                    obj.VelocAcc = obj.VelocAcc + ...
                        FreqErInput  * obj.CoefsFLL(2) * obj.T + ...
                        FreqErInput  * obj.CoefsFLL(1) * obj.T * 0.5 * obj.T + ...
                        ...
                        obj.AccelAcc *  obj.T;

                    obj.AccelAcc = obj.AccelAcc + ...
                        FreqErInput  * obj.CoefsFLL(1) *  obj.T;
                    
                    
                    

                end
            end
            AccelAcc = obj.AccelAcc;
            VelocAcc = obj.VelocAcc;
        end
    end
end

function Coefs = CalcCoefs(Order, Bn)
% ������� ������� ������������� ������� �� �������� ������� �������
% � ��� ������. ������� ����� �� Kaplan: page 180, Table 5.6.
%
% ������� ���������
%   Order - 1 | 2 | 3;
%   Bn    - �������� >0 � ��.
% �������� ����������
%   Coefs - ������ [1xOrder] ������������� �������.
    switch Order
        case 1
            w0 = Bn/0.25;
            Coefs =  ...
                w0;
        case 2
            w0 = Bn/0.53;
            Coefs = [ ...
                w0^2, ...
                1.414*w0];
        case 3
            w0 = Bn/0.7845;
            Coefs = [ ...
                w0^3, ...
                1.1*w0^2, ...
                2.4*w0];
    end
end