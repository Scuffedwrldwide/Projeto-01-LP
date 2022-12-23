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
    organizaEventos(Eventos, Periodo, [], ToSort), bubbleSort(ToSort, EventosNoPeriodo).    % Inclui uma variável acumuladora para os periodos encontrados.
                                                        
organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    ((P = Periodo; ehPeriodo(Periodo, P)) -> 
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).


eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    eventosMenoresQue(Duracao, [], ListaEventosMenoresQue).     % Inclui uma variável acumuladora para os IDs encontrados.
%eventosMenoresQue(_, Eventos, Eventos).
eventosMenoresQue(Duracao, Acc, ListaEventosMenoresQue) :-
    horario(ID, _, _, _, Time, _),
    (Duracao is Time ->
        eventosMenoresQue(Duracao, [ID|Acc], ListaEventosMenoresQue)
    ;
        eventosMenoresQue(Duracao, Acc, ListaEventosMenoresQue)   
    ).

eventosMenoresQueBool(ID, Duracao) :- horario(ID, _, _, _, Time, _), Time =< Duracao.

% Auxiliares


bubbleSort(ToSort, Sorted) :-
    switcharoo(ToSort, Sort1), !,         % Após a troca de elementos, a chamada recursiva %
    bubbleSort(Sort1, Sorted).            % é feita até não serem possíveis mais trocas.   %

bubbleSort(Sorted, Sorted).             % Caso terminal, no qual a lista a ordenar e a ordenada são iguais.

switcharoo([X, Y|R], [Y,X|R]) :- X > Y. % Caso base, no qual a troca de elementos é necessária.
switcharoo([Z|R], [Z|R1]) :-            % Caso recursivo, que "investiga" a lista em profundidade.
    switcharoo(R, R1).                    



ehPeriodo(Periodo, P) :-                %  Os eventos com mais que um periodo resultam da concatenação de, eg., p1_p2. %
    sub_atom(P, _, _, _, Periodo).      %  o predicado ehPeriodo/2 permite verificar a pertença a um destes periodos   %
                                        %  sendo Periodo o periodo desejado e P a variavel constante no horario/6.     %
/*TODO

- Metapredicados no organizaEventos
- Implement own sorting system
- Slim down ehPeriodo √
- Fix whatever the fuck is up with Eventos √
- less reverse() use
- figure out singletons
- less findall()

*/