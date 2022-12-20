% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).

eventosSemSalasDiaSemana(DiaSemana, EventosSemSala) :-
    eventosSemSalasDiaSemana(DiaSemana, [], EventosSemSala).     % Inclui uma variável acumuladora para os eventos encontrados
eventosSemSalasDiaSemana(_, EventosSemSala, EventosSemSala).     % Conclui a execução quando a variável acumuladora é unificada com os eventos sem sala
eventosSemSalasDiaSemana(DiaSemana, Acc, EventosSemSala) :-
    eventosSemSalas([ID|R]),                                    % NOT EXCLUDING ID ON NEXT LOOP, FIX LATER
    horario(ID, DiaSemana, _, _, _, _),
    eventosSemSalasDiaSemana(DiaSemana, [ID|Acc], EventosSemSala).


% Pesquisas Simples
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :-
    organizaEventos(Eventos, Periodo, [], EventosNoPeriodo).    % Inclui uma variável acumuladora para os periodos encontrados

/* Os eventos com mais que um periodo resultam da concatenação de, eg., p1_p2. 
   o predicado ehPeriodo/2 permite verificar a pertença a um destes periodos  
   sendo Periodo o periodo desejado e P a variavel constante no horario/6     */
ehPeriodo(Periodo, P) :-
    atom_concat(Periodo, '_', Outro), atom_concat(Outro, '_', Periodo),

organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    (ehPeriodo(Periodo, P) ->
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).

                                    