% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).


eventosSemSalasDiaSemana(DiaSemana, Eventos) :-
    eventosSemSalasDiaSemana(DiaSemana, [], Eventos).           % Inclui uma variável acumuladora para os eventos encontrados

eventosSemSalasDiaSemana(_, Eventos, Eventos).    
eventosSemSalasDiaSemana(DiaSemana, Acc, Eventos) :-
    (
    eventosSemSalas(Eventos),                                   % NOT EXCLUDING ID ON NEXT LOOP, FIX LATER
    ([ID|R] = Eventos),
    horario(ID, DiaSemana, _, _, _, _),
    eventosSemSalasDiaSemana(DiaSemana, [ID|Acc], R));
    eventosSemSalasDiaSemana(DiaSemana, Acc, R).


% Pesquisas Simples
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(Eventos, Periodo, [], ToSort), msort(ToSort, EventosNoPeriodo).    % Inclui uma variável acumuladora para os periodos encontrados
                                                        % MIGHT BE ABLE TO REMOVE THIS
/* Os eventos com mais que um periodo resultam da concatenação de, eg., p1_p2. 
   o predicado ehPeriodo/2 permite verificar a pertença a um destes periodos  
   sendo Periodo o periodo desejado e P a variavel constante no horario/6     */
ehPeriodo(Periodo, P) :-
    sub_atom(Periodo, 1, 1, After, Num),    % Verifica que existe um Numero no periodo dado
    sub_atom(P, Before, 1, After, Num).     % e que esse numero está presente no horario

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
- Slim down ehPeriodo
- Fix whatever the fuck is up with Eventos
- less reverse() use
- figure out singletons

*/