% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).

eventosSemSalasDiaSemana(DiaSemana, Eventos) :-             % Lista de eventos sem sala num dado dia da semana
    findall(ID, horario(ID, DiaSemana, _, _, _, _), NoDia),
    eventosSemSalas(EventosSemSala),
    intersection(NoDia, EventosSemSala, Eventos).

eventosSemSalasPeriodo([], []).
eventosSemSalasPeriodo(Periodos, SemSalaNoPeriodo) :-
    findall(ID, 
                (horario(ID, _, _, _, _, P),             
                 member(Periodo, Periodos),
                 ehPeriodo(Periodo, P)),
            NoPeriodo),
    eventosSemSalas(EventosSemSala),
    intersection(NoPeriodo, EventosSemSala, SemSalaUnsorted),
    sort(SemSalaUnsorted, SemSalaNoPeriodo).


% Pesquisas Simples
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(Eventos, Periodo, [], ToSort), sort(ToSort, EventosNoPeriodo).    % Inclui uma variavel acumuladora para os periodos encontrados.
                                                        
organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).     % Caso base - uma lista vazia de IDs implica que todos os eventos ja se encontram organizados

organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    ((P = Periodo; ehPeriodo(Periodo, P)) ->                    % Se o evento estiver no periodo pretendido, ou num semestre que o englobe, adiciona-o a lista de eventos
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)      % Caso contrario, o evento nao e adicionado
    ).

eventosMenoresQueBool(ID, Duracao) :- horario(ID, _, _, _, Time, _), Time =< Duracao.    % Verifica se um evento tem uma duracao menor que a dada

eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-                                    % Lista de eventos com duracao menor que a dada
    findall(ID, eventosMenoresQueBool(ID, Duracao), ListaEventosMenoresQue).

procuraDisciplinas(Curso, ListaDisciplinasCurso) :-                                      % Lista de disciplinas de um dado curso
    idsCurso(Curso, ListaTurnosCurso),                                                  
    discFinder(ListaTurnosCurso, ListaDisciplinasCurso).

organizaDisciplinas(ListaDisciplinas, Curso, [Sem1, Sem2]) :-                            % Organiza uma dada lista de disciplinas, dividindo-a por semestres
    idsCurso(Curso, ListaIDsCurso),
    organizaEventos(ListaIDsCurso, p1, IDsP1), organizaEventos(ListaIDsCurso, p2, IDsP2),% Organiza os eventos relativos ao 1o e 2o periodo
        union(IDsP1, IDsP2, IDsSem1),
    organizaEventos(ListaIDsCurso, p3, IDsP3), organizaEventos(ListaIDsCurso, p4, IDsP4),% Organiza os eventos relativos ao 3o e 4o periodo
        union(IDsP3, IDsP4, IDsSem2),
    discFinder(IDsSem1, TotalDisc1), discFinder(IDsSem2, TotalDisc2),                    % Lista de disciplinas de cada semestre
        intersection(ListaDisciplinas, TotalDisc1, Sem1), 
        intersection(ListaDisciplinas, TotalDisc2, Sem2),
    Sem1 \= [], Sem2 \= [].                                                              % Condicao de falha - se nao existir uma disciplina da lista no Curso, a interseccao e vazia

horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    idsCurso(Curso, ListaIDsCurso, Ano),
    organizaEventos(ListaIDsCurso, Periodo, ListaIDsPeriodo),
    findall(Time, (member(ID, ListaIDsPeriodo), horario(ID, _, _, _, Time, _)), ListaHoras),
    sum_list(ListaHoras, TotalHoras).

evolucaoHorasCurso(Curso, Evolucao) :- 
    findall(Ano, turno(_, Curso, Ano, _), A),           % Introduz-se a lista de anos de um dado curso, sob a qual se baseia o processo recursivo
    sort(A, ListaAnos),
    evolucaoHorasCurso(ListaAnos, Curso, Evolucao).
    
evolucaoHorasCurso([], _, []).
evolucaoHorasCurso([Ano|R1], Curso, [(Ano,p1,Horas1),   % Lista de tuplos compostos pelo ano, periodo e horas de um dado curso
                                     (Ano,p2,Horas2),
                                     (Ano,p3,Horas3),
                                     (Ano,p4,Horas4)
                                     |R2]) :-
    horasCurso(p1, Curso, Ano, Horas1),
    horasCurso(p2, Curso, Ano, Horas2),
    horasCurso(p3, Curso, Ano, Horas3),
    horasCurso(p4, Curso, Ano, Horas4),
    evolucaoHorasCurso(R1, Curso, R2).                  % Apura-se a evolucao de horas de cada ano, recursivamente


% Ocupacoes Criticas de Slas

ocupaSlot(HoraInicioDada, HoraFimDada, HoraInicioEvento, HoraFimEvento, Horas) :-
    ((HoraInicioDada =< HoraInicioEvento,
     HoraFimDada =< HoraFimEvento,
     Horas is HoraFimDada - HoraInicioEvento, !);    % Evento 'depois' do slot
    (HoraInicioDada >= HoraInicioEvento,
     HoraFimDada >= HoraFimEvento,
     Horas is HoraFimEvento - HoraInicioDada, !);    % Evento 'depois' do slot
    (HoraInicioDada >= HoraInicioEvento,
     HoraFimDada =< HoraFimEvento,
     Horas is HoraFimDada - HoraInicioDada, !);      % Slot 'dentro' do evento
    (HoraInicioDada =< HoraInicioEvento,
     HoraFimDada >= HoraFimEvento,
     Horas is HoraFimEvento - HoraInicioEvento, !)), % Evento 'dentro' do Slot
    \+ Horas =< 0.                                   % Garante que o evento se sobrepoe ao slot

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :- % Numero de horas ocupadas num dado periodo, tipo de sala, dia da semana e slot
    salas(TipoSala, ListaSalas),
    findall(Horas, (member(Sala, ListaSalas),
                    evento(ID, _, _, _, Sala),
                    horario(ID, DiaSemana, HoraInicioEvento, HoraFimEvento, _, P),
                    ehPeriodo(Periodo, P),
                    ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, Horas)),
            ListaHoras),
    sum_list(ListaHoras, SomaHoras).

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-    % Ocupacao maxima possivel para um tipo de sala durante um dado slot, expressa em horas
    salas(TipoSala, ListaSalas),
    length(ListaSalas, NumSalas),
    Max is NumSalas * (HoraFim - HoraInicio).

percentagem(SomaHoras, Max, Percentagem) :-           
    Percentagem is SomaHoras / Max * 100.

ocupacaoCritica(HoraInicio, HoraFim, Threshhold, Casos) :-
    Dias = [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira],
    findall(TiposSala, salas(TiposSala, _), Salas),
    ocupacaoCritica(HoraInicio, HoraFim, Threshhold, Casos, Dias, Salas).

ocupacaoCritica(_, _, _, [], [], _).
ocupacaoCritica(HoraInicio, HoraFim, Threshhold, CasosNext, [_|R1], []) :-  % A ordem da lista de tuplos rege-se respetivamente por Dia, Tipo de Sala e Percentagem                       %
    findall(TiposSala, salas(TiposSala, _), Salas),                         % assim, os casos criticos sao analizados dia a dia. Esgotada uma semana, analiza-se o tipo de sala seguinte. %     
    ocupacaoCritica(HoraInicio, HoraFim, Threshhold, CasosNext, R1, Salas).
ocupacaoCritica(HoraInicio, HoraFim, Threshhold, CasosCriticos, [Dia|R1], [TipoSala|R2]) :- % Lista de casos criticos, na forma casosCriticos(Dia, TipoSala, Percentagem), %
    findall(casosCriticos(Dia, TipoSala, Arr),                                              % Isto e, os casos nos quais a ocupacao excede um dado valor.                  %
               (member(Periodo, [p1, p2, p3, p4]),
                %member(Dia, [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira]),
                numHorasOcupadas(Periodo, TipoSala, Dia, HoraInicio, HoraFim, SomaHoras),
                ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
                percentagem(SomaHoras, Max, Percentagem),
                ceiling(Percentagem, Arr),                  % O valor da percentagem e arredondado por excesso
                Percentagem > Threshhold),                  
            CasosUnsorted),
    sort(3, @=<, CasosUnsorted, Casos),                     % No contexto de um dado dia e sala, a lista de casos e ordenada de forma crescente com base na percentagem  
    ocupacaoCritica(HoraInicio, HoraFim, Threshhold, CasosNext, [Dia|R1], R2),
    append(Casos, CasosNext, CasosCriticos).

/*ocupacaoCritica(HoraInicio, HoraFim, Threshhold, Tuplos) :- % Lista de casos criticos, na forma casosCriticos(Dia, TipoSala, Percentagem) %
    findall(casosCriticos(Dia, TipoSala, Arr),              % estes sao os casos nos quais a ocupacao excede um dado valor.               %
               (member(Periodo, [p1, p2, p3, p4]),
                member(Dia, [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira]),
                numHorasOcupadas(Periodo, TipoSala, Dia, HoraInicio, HoraFim, SomaHoras),
                ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
                percentagem(SomaHoras, Max, Percentagem),
                ceiling(Percentagem, Arr),                  % O valor da percentagem é arredondado por excesso
                Percentagem > Threshhold),                  
            Tuplos).
*/
% And Now For Something Completely Different
/*
                      Lado 1
                X1      X2      X3
            +------------------------+
            |                        |
   Cab1  X4 |                        | X5  Cab2
            |                        |
            +------------------------+
                X6      X7      X8
                      Lado 2
*/
ocupacaoMesa(ListaPessoas, ListaRestricoes, OcupacaoMesa) :-
    permutation(ListaPessoas, [X1, X2, X3, X4, X5, X6, X7, X8]),
    check_restrictions(ListaRestricoes, X1, X2, X3, X4, X5, X6, X7, X8),!,
    OcupacaoMesa = [[X1, X2, X3], [X4, X5], [X6, X7, X8]].

check_restrictions([], _, _, _, _, _, _, _, _).
check_restrictions([Restricao|T], X1, X2, X3, X4, X5, X6, X7, X8) :-
    (Restricao = cab1(X), X = X4;
     Restricao = cab2(X), X = X5;
     Restricao = honra(X, Y), ((X = X4, Y = X3); (X = X5, Y = X6));
     Restricao = lado(X, Y), ((X = X7, Y = X8); (X = X2, Y = X3));
     Restricao = naoLado(X, Y), ((X = X1, Y = X3); (X = X6, Y = X8));
     Restricao = frente(X, Y), (X = X7, Y = X2);
     Restricao = naoFrente(X, Y), (X = X7, Y = X3)),
    check_restrictions(T, X1, X2, X3, X4, X5, X6, X7, X8).



% Auxiliares

discFinder(ListaTurnos, ListaDisciplinas) :-      % Encontra as disciplinas associadas a uma dada lista de IDs de turnos.
    findall(Disciplina, (member(ID, ListaTurnos), evento(ID, Disciplina, _, _, _)), Lista),
    sort(Lista, ListaDisciplinas).

idsCurso(Curso, ListaIDs) :-                      % Encontra todos os IDs dos turnos de um dado curso. 
    findall(ID, turno(ID, Curso, _, _), Lista),
    sort(Lista, ListaIDs).
idsCurso(Curso, ListaIDs, Ano) :-                 % Encontra todos os IDs dos turnos de um dado curso, limitado a um dado ano. 
    findall(ID, turno(ID, Curso, Ano, _), Lista),
    sort(Lista, ListaIDs).

dias(Dias) :- Dias = [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira]. % Lista de dias da semana.

bubbleSort(ToSort, Sorted) :-
    switcharoo(ToSort, Sort1), !,       % Apos a troca de elementos, a chamada recursiva  %
    bubbleSort(Sort1, Sorted).          % e efetuada ate nao serem possiveis mais trocas. %
bubbleSort(Sorted, Sorted).             % Caso terminal, no qual a lista aordenar e a ordenada sao iguais.

switcharoo([X, Y|R], [Y,X|R]) :- X > Y. % Caso base, no qual a troca de elementos e necessaria.
switcharoo([Z|R1], [Z|R2]) :-           % Caso recursivo, que 'investiga' a lista em profundidade.
    switcharoo(R1, R2).                    

ehPeriodo(Periodo, P) :-                % Os eventos com mais que um periodo resultam da concatenacao de, eg., p1_p2. 
    sub_atom(Periodo, 1, 1, _, Num),    % Este predicado determina que Num corresponde ao numero do periodo,
    sub_atom(P, _, _, _, Num).          % seguindo-se a condicao que este Num esta presente no semestre.   

/*
           __-----_.                        ______
          /  \      \           o  O  O   _(      )__
         /    |  |   \_---_   o._.      _(           )_
        |     |            \   | |""""(_   Let's see... )
        |     |             |@ | |    (_               _)
         \___/   ___       /   | |      (__          _)
           \____(____\___/     | |         (________)
           |__|                | |          |
           /   \-_             | |         |'
         /      \_ "__ _       !_!--v---v--"
        /         "|  |>)      |""""""""|
       |          _|  | ._--""||        |
       _\_____________|_|_____||________|_
      /                                   \
     /_____________________________________\
     /                                     \
    /_______________________________________\
    /                                       \
   /_________________________________________\
        {                               }
        <_______________________________|
        |                               >
        {_______________________________|               ________
        <                               }              / SNOOPY \
        |_______________________________|             /__________\
\|/       \\/             \||//           |//                       \|/    |/ */