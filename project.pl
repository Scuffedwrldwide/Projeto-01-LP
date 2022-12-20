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
    organizaEventos(Eventos, Periodo, [], ToReverse), reverse(ToReverse, EventosNoPeriodo).    % Inclui uma variável acumuladora para os periodos encontrados
                                                        % MIGHT BE ABLE TO REMOVE THIS
/* Os eventos com mais que um periodo resultam da concatenação de, eg., p1_p2. 
   o predicado ehPeriodo/2 permite verificar a pertença a um destes periodos  
   sendo Periodo o periodo desejado e P a variavel constante no horario/6     */
ehPeriodo(Periodo, P) :-
    sub_atom(P, Before, 2, After, Periodo).

organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    ((P = Periodo; ehPeriodo(Periodo, P)) -> 
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).

                                    