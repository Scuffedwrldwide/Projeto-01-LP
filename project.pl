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
eventosSemSalasPeriodo([Periodo|R], [Evento|Outros]) :-
    findall(ID, 
                (horario(ID, _, _, _, _, P), 
                 ehPeriodo(Periodo, P)),
            NoPeriodo),
    eventosSemSalas(EventosSemSala),
    intersection(NoPeriodo, EventosSemSala, Evento),
    eventosSemSalasPeriodo(R, Outros).


% Pesquisas Simples
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(Eventos, Periodo, [], ToSort), bubbleSort(ToSort, EventosNoPeriodo).    % Inclui uma variavel acumuladora para os periodos encontrados.
                                                        
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
    
numHorasOcupadas(Periodo, TipoSala, DiaSemana, HoraInicio, HoraFim, SomaHoras) :- 
    findall(Time, (horario(ID, DiaSemana, HoraInicio, HoraFim, Time, P), 
                   ehPeriodo(Periodo, P)), ListaHoras),
    sum_list(ListaHoras, SomaHoras).

% Auxiliares

discFinder(ListaTurnos, ListaDisciplinas) :-
    findall(Disciplina, (member(ID, ListaTurnos), evento(ID, Disciplina, _, _, _)), Lista),
    sort(Lista, ListaDisciplinas).
idsCurso(Curso, ListaIDs) :-
    findall(ID, turno(ID, Curso, _, _), ListaIDs).

/*discFinder([], _).
discFinder([ID|R1], [Disciplina|R2]) :-
    evento(ID, Disciplina, _, _, _),
    \+ member(Disciplina, R2),
    discFinder(R1, R2).
discFinder([ID|R1], R2) :-
    evento(ID, _, _, _, _),
    discFinder(R1, R2).*/


bubbleSort(ToSort, Sorted) :-
    switcharoo(ToSort, Sort1), !,       % Apos a troca de elementos, a chamada recursiva  %
    bubbleSort(Sort1, Sorted).          % e efetuada ate nao serem possiveis mais trocas. %
bubbleSort(Sorted, Sorted).             % Caso terminal, no qual a lista aordenar e a ordenada sao iguais.

switcharoo([X, Y|R], [Y,X|R]) :- X > Y. % Caso base, no qual a troca de elementos e necessaria.
switcharoo([Z|R1], [Z|R2]) :-           % Caso recursivo, que 'investiga' a lista em profundidade.
    switcharoo(R1, R2).                    

/*duplicateRemover([], []).
duplicateRemover([X|R], Result) :-
    member(X, R),
    duplicateRemover(R, Result).
duplicateRemover([X|R], [X|Result]) :-
    \+ member(X, R),
    duplicateRemover(R, Result).*/



ehPeriodo(Periodo, P) :-                %  Os eventos com mais que um periodo resultam da concatenacao de, eg., p1_p2. %
    sub_atom(P, _, _, _, Periodo).      %  o predicado ehPeriodo/2 permite verificar a pertenca a um destes periodos   %
                                        %  sendo Periodo o periodo desejado e P a variavel constante no horario/6.     %




/*TODO

- Metapredicados no organizaEventos
- Implement own sorting system      (DONE)
- Slim down ehPeriodo               (DONE)
- less reverse() use                (DONE)
- figure out singletons             (DONE)
- less findall()
*/