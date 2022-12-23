% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).


eventosSemSalasDiaSemana(DiaSemana, Eventos) :- findall(ID, horario(ID, DiaSemana, _, _, _, _), NoDia),
                                                eventosSemSalas(EventosSemSala),
                                                intersection(NoDia, EventosSemSala, Eventos).


eventosSemSalasPeriodo([], []).
eventosSemSalasPeriodo([Periodo|R], [Evento|Outros]) :-
                                              
                                              findall(ID, (horario(ID, _, _, _, _, P), 
                                                           ehPeriodo(Periodo, P)), 
                                                           NoPeriodo),
                                              eventosSemSalas(EventosSemSala),
                                              intersection(NoPeriodo, EventosSemSala, Evento),
                                              %append(Corrente, Evento),
                                              eventosSemSalasPeriodo(R, Outros).

/*eventosSemSalasDiaSemana(DiaSemana, Eventos) :-
    eventosSemSalasDiaSemana(DiaSemana, [], Eventos).           % Inclui uma variável acumuladora para os eventos encontrados

eventosSemSalasDiaSemana(_, Eventos, []) :- Eventos \= [] .     % Caso terminal, impede a unificação de Eventos com []
eventosSemSalasDiaSemana(DiaSemana, Acc, [ID|R]) :-
    eventosSemSalas(EventosSemSala),
    member(ID, EventosSemSala),                                 % Verifica a correspondencia de um ID a um evento sem sala
    horario(ID, DiaSemana, _, _, _, _),
    eventosSemSalasDiaSemana(DiaSemana, [ID|Acc], R).           % Adiciona o ID encontrado ao acumulador
eventosSemSalasDiaSemana(DiaSemana, Acc, [_|R]) :-              % Caso o ID não corresponda, este não é adicionado
    eventosSemSalasDiaSemana(DiaSemana, Acc, R).                % Avança-se recursiamente para os restantes eventos


eventosSemSalasPeriodo(Periodo, Eventos) :-
    eventosSemSalasPeriodo(Periodo, [], Eventos).               % Inclui uma variável acumuladora para os eventos encontrados

eventosSemSalasPeriodo(_, Eventos, []) :- Eventos \= [] .       % Caso terminal, impede a unificação de Eventos com []
eventosSemSalasPeriodo([Periodo | Next] , Acc, [ID|R]) :-
    eventosSemSalas(EventosSemSala),
    member(ID, EventosSemSala),                                 % Verifica a correspondencia de um ID a um evento sem sala
    horario(ID, _, _, _, _, P),
    ehPeriodo(Periodo, P),                                      % Um evento pode ocorrer em multiplos períodos
    eventosSemSalasPeriodo(Next, [ID|Acc], R).                  % Adiciona o ID encontrado ao acumulador
eventosSemSalasPeriodo([Periodo | Next], Acc, [_|R]) :-         % Caso o ID não corresponda, este não é adicionado
    eventosSemSalasPeriodo(Next, Acc, R).                       % Avança-se recursiamente para os restantes eventos
*/


% Pesquisas Simples
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(Eventos, Periodo, [], ToSort), msort(ToSort, EventosNoPeriodo).    % Inclui uma variável acumuladora para os periodos encontrados
                                                        % MIGHT BE ABLE TO REMOVE THIS
/* Os eventos com mais que um periodo resultam da concatenação de, eg., p1_p2. 
   o predicado ehPeriodo/2 permite verificar a pertença a um destes periodos  
   sendo Periodo o periodo desejado e P a variavel constante no horario/6     */
ehPeriodo(Periodo, P) :-
    sub_atom(Periodo, 1, 1, After, Num),    % Verifica que existe um Numero no periodo dado
    sub_atom(P, _, 1, After, Num).     % e que esse numero está presente no horario

organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    ((P = Periodo; ehPeriodo(Periodo, P)) -> 
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).


eventosMenoresQue(Duracao, ListaEventosMenoresQue) :-
    eventosMenoresQue(Duracao, [], ListaEventosMenoresQue).     % Inclui uma variável acumuladora para os IDs encontrados
%eventosMenoresQue(_, Eventos, Eventos).
eventosMenoresQue(Duracao, Acc, ListaEventosMenoresQue) :-
    horario(ID, _, _, _, Time, _),
    (Duracao is Time ->
        eventosMenoresQue(Duracao, [ID|Acc], ListaEventosMenoresQue)
    ;
        eventosMenoresQue(Duracao, Acc, ListaEventosMenoresQue)   
    ).

eventosMenoresQueBool(ID, Duracao) :- horario(ID, _, _, _, Time, _), Time =< Duracao.

/*TODO

- Implement own sorting system
- Slim down ehPeriodo √
- Fix whatever the fuck is up with Eventos √
- less reverse() use
- figure out singletons
- less findall()

*/