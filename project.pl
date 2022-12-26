% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).

eventosSemSalasDiaSemana(DiaSemana, Eventos) :- 
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
                                                        
organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    ((P = Periodo; ehPeriodo(Periodo, P)) -> 
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).

eventosMenoresQueBool(ID, Duracao) :- horario(ID, _, _, _, Time, _), Time =< Duracao.

eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    findall(ID, eventosMenoresQueBool(ID, Duracao), ListaEventosMenoresQue).

procuraDisciplinas(Curso, ListaDisciplinasCurso) :-
    idsCurso(Curso, ListaTurnosCurso),
    discFinder(ListaTurnosCurso, ListaDisciplinasCurso).

organizaDisciplinas(ListaDisciplinas, Curso, [Sem1, Sem2]) :-
    idsCurso(Curso, ListaIDsCurso),
    organizaEventos(ListaIDsCurso, p1, IDsP1), organizaEventos(ListaIDsCurso, p2, IDsP2),
        union(IDsP1, IDsP2, IDsSem1),
    organizaEventos(ListaIDsCurso, p3, IDsP3), organizaEventos(ListaIDsCurso, p4, IDsP4),
        union(IDsP3, IDsP4, IDsSem2),
    discFinder(IDsSem1, TotalDisc1), discFinder(IDsSem2, TotalDisc2),
        intersection(ListaDisciplinas, TotalDisc1, Sem1), 
        intersection(ListaDisciplinas, TotalDisc2, Sem2),
    Sem1 \= [], Sem2 \= [].
    
horasCurso(Periodo, Curso, Ano, TotalHoras) :-
    idsCurso(Curso, ListaIDsCurso, Ano),
    organizaEventos(ListaIDsCurso, Periodo, ListaIDsPeriodo),
    findall(Time, (member(ID, ListaIDsPeriodo), horario(ID, _, _, _, Time, _)), ListaHoras),
    sum_list(ListaHoras, TotalHoras).

evolucaoHorasCurso(Curso, Evolucao) :- 
    findall(Ano, turno(_, Curso, Ano, _), A),
    sort(A, ListaAnos),
    evolucaoHorasCurso(ListaAnos, Curso, Evolucao).
    
evolucaoHorasCurso([], _, []).
evolucaoHorasCurso([Ano|R1], Curso, [(Ano,p1,Horas1), 
                                     (Ano,p2,Horas2),
                                     (Ano,p3,Horas3),
                                     (Ano,p4,Horas4)
                                     |R2]) :-
    horasCurso(p1, Curso, Ano, Horas1),
    horasCurso(p2, Curso, Ano, Horas2),
    horasCurso(p3, Curso, Ano, Horas3),
    horasCurso(p4, Curso, Ano, Horas4),
    evolucaoHorasCurso(R1, Curso, R2).


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

numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :- 
    salas(TipoSala, ListaSalas),
    findall(Horas, (member(Sala, ListaSalas),
                    evento(ID, _, _, _, Sala),
                    horario(ID, DiaSemana, HoraInicioEvento, HoraFimEvento, _, P),
                    ehPeriodo(Periodo, P),
                    ocupaSlot(HoraInicio, HoraFim, HoraInicioEvento, HoraFimEvento, Horas)),
            ListaHoras),
    sum_list(ListaHoras, SomaHoras).

ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max) :-
    salas(TipoSala, ListaSalas),
    length(ListaSalas, NumSalas),
    Max is NumSalas * (HoraFim - HoraInicio).

percentagem(SomaHoras, Max, Percentagem) :-
    Percentagem is SomaHoras / Max * 100.

ocupacaoCritica(HoraInicio, HoraFim, Threshhold, Tuplos) :-
    findall((Dia, TipoSala, Arr), 
           (member(Periodo, [p1, p2, p3, p4]),
            member(Dia, [segunda-feira, terca-feira, quarta-feira, quinta-feira, sexta-feira]),
            numHorasOcupadas(Periodo, TipoSala, Dia, HoraInicio, HoraFim, SomaHoras),
            ocupacaoMax(TipoSala, HoraInicio, HoraFim, Max),
            percentagem(SomaHoras, Max, Percentagem),
            ceiling(Percentagem, Arr),
            Percentagem > Threshhold), Tuplos).

% Auxiliares

discFinder(ListaTurnos, ListaDisciplinas) :-      % Encontra as disciplinas associadas a uma dada lista de IDs de turnos.
    findall(Disciplina, (member(ID, ListaTurnos), evento(ID, Disciplina, _, _, _)), Lista),
    sort(Lista, ListaDisciplinas).

idsCurso(Curso, ListaIDs) :-                      % Encontra os IDs dos turnos de um dado curso. 
    findall(ID, turno(ID, Curso, _, _), Lista),
    sort(Lista, ListaIDs).
idsCurso(Curso, ListaIDs, Ano) :-                 % Encontra os IDs dos turnos de um dado curso, limitado a um dado ano. 
    findall(ID, turno(ID, Curso, Ano, _), Lista),
    sort(Lista, ListaIDs).

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

/*TODO

- Metapredicados no organizaEventos
- Implement own sorting system      (DONE)
- Slim down ehPeriodo               (DONE)
- less reverse() use                (DONE)
- figure out singletons             (DONE)
- less findall()
*/