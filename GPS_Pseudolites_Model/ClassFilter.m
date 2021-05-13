classdef ClassFilter < handle
% Описание класса для loop filter типа DLL или FLL-assisted PLL filter    
    properties
        % Вариант фильтра (DLL) или (FLL, PLL)
            isDLL;
        % Порядок фильтра [1], [2], [3] (DLL) или [1, 2], [2, 3] (FLL, PLL)
            Order;
        % Полоса фильтров DLL, FLL, PLL
            Bnd, Bnf, Bnp;
        % Шаг поступления отсчётов, сек
            T;
        % Аккумуляторы хранения скорости и ускорения
            VelocAcc, AccelAcc;
        % Коэффициенты фильтров DLL, FLL, PLL
            CoefsDLL, CoefsFLL, CoefsPLL;
    end
    methods
        function PrepareFilter(obj, Order, Bn, T, VelocAcc, AccelAcc)
        % Функция инициализации фильтра
        %
        % Входные параметры
        %   Order - 1 | 2 | 3 | [1, 2] | [2, 3];
        %   Bn    - 1 или 2 элемента в массиве, значения >0 в Гц.
        %   T     - значение >0 в секундах.
        %   VelocAcc, AccelAcc - необязательные переменные для
        %       инициализации аккумуляторов
        
%         PrepareFilter(FPLL.FilterOrder, FPLL.FilterBands(...
%                 FPLL.State, :), TCA*FPLL.NumIntCA, -FreqShift*2*pi, 0);
            
            % Определим тип фильтра
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
                    sprintf(['Недопустимый порядок фильтра Order ', ...
                        'и/или полоса(ы) фильтра Bn!\n']);
                    return
                end

            % Сохраним параметры фильтра внутри объекта
                obj.Order = Order;
                if obj.isDLL
                    obj.Bnd = Bn(1);
                else
                    obj.Bnf = Bn(1);
                    obj.Bnp = Bn(2);
                end
                obj.T = T;

            % Расчитаем коэффициенты фильтров DLL, FLL и PLL
                if obj.isDLL
                    obj.CoefsDLL = CalcCoefs(Order(1), obj.Bnd);
                else
                    obj.CoefsFLL = CalcCoefs(Order(1), obj.Bnf);
                    obj.CoefsPLL = CalcCoefs(Order(2), obj.Bnp);
                end
            
            % Инициализируем значения аккумуляторов скорости и ускорения
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
            % Сохраним параметры фильтра внутри объекта
                if obj.isDLL
                    obj.Bnd = Bn(1);
                else
                    obj.Bnf = Bn(1);
                    obj.Bnp = Bn(2);
                end
                obj.T = T;

            % Расчитаем коэффициенты фильтров DLL, FLL и PLL
                if obj.isDLL
                    obj.CoefsDLL = CalcCoefs(obj.Order(1), obj.Bnd);
                else
                    obj.CoefsFLL = CalcCoefs(obj.Order(1), obj.Bnf);
                    obj.CoefsPLL = CalcCoefs(obj.Order(2), obj.Bnp);
                end
            
            % Инициализируем значения аккумуляторов скорости и ускорения
                if nargin > 3
                    obj.VelocAcc = VelocAcc;
                end
                if nargin > 4
                    obj.AccelAcc = AccelAcc;
                end
        end
        function [Output, VelocAcc, AccelAcc] = Step(obj, Inp1, Inp2)
        % Функция выполнения действий одного шага фильтра
        % Формулы соответствуют Kaplan: page 181, fig 5.20
        %
        % Входные параметры
        %   Inp1, Inp2 - для isDLL = true используется только Inp1 и оно
        %       равно значению с выхода дискриминатора DLL, для isDLL =
        %       false соответственно Inp1 - значение с выхода
        %       дискриминатора FLL и Inp2 - значение с выхода
        %       дискриминатора PLL
        % Выходные переменные
        %   Output - значение, которое нужно подать на NCO
        %   VelocAcc, AccelAcc - текущие значения аккумуляторов

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
% Функция расчёта коэффициентов фильтра по заданным порядку фильтра
% и его полосе. Формулы взяты из Kaplan: page 180, Table 5.6.
%
% Входные параметры
%   Order - 1 | 2 | 3;
%   Bn    - значение >0 в Гц.
% Выходные переменные
%   Coefs - массив [1xOrder] коэффициентов фильтра.
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