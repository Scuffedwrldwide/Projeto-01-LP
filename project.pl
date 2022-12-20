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
%organizaEventos([], Periodo, [_|_]).             % Caso Terminal
%organizaEventos([ID|R], Periodo, EventosNoPeriodo) :- (horario(ID, _, _, _, _, Periodo), organizaEventos(R, Periodo, [ID|_])); %NOT WORKING YET, RETURNS TRUE
%                                                       organizaEventos(R, Periodo, [_|R]).
pertenceHorario(ID, Periodo) :- horario(ID, _, _, _, _, Periodo).
organizaEventos(Eventos, Periodo, EventosNoPeriodo) :- convlist(pertenceHorario(IDs, Periodo), IDs, EventosNoPeriodo).

                                    