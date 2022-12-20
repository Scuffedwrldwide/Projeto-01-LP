% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).
%eventosSemSalasDiaSemana(DiaSemana, []).
eventosSemSalasDiaSemana(DiaSemana, EventosSemSala) :- (eventosSemSalas([ID|_]),
                                                       horario(ID, DiaSemana, _, _, _, _,),
                                                       eventosSemSalasDiaSemana(DiaSemana, R));
                                                       (eventosSemSalas(R),
                                                       eventosSemSalasDiaSemana(DiaSemana, R)).


% Pesquisas Simples

organizaEventos([], _, EventosNoPeriodo, EventosNoPeriodo).
organizaEventos([ID|R], Periodo, Acc, EventosNoPeriodo) :-
    horario(ID, _, _, _, _, P),
    (P = Periodo ->
        organizaEventos(R, Periodo, [ID|Acc], EventosNoPeriodo)
    ;
        organizaEventos(R, Periodo, Acc, EventosNoPeriodo)
    ).

                                    