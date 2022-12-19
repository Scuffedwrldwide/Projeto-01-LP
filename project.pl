% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).
eventosSemSalasDiaSemana(DiaSemana, []).
eventosSemSalasDiaSemana(DiaSemana, EventosSemSala) :- eventosSemSalas([ID|R]),
                                                       horario(ID, DiaSemana, _, _, _, _,),
                                                       EventosSemSala = [ID|_],
                                                       eventosSemSalasDiaSemana(DiaSemana, R);
                                                       eventosSemSalas([ID|R]),
                                                       eventosSemSalasDiaSemana(DiaSemana, R).


% Pesquisas Simples
organizaEventos([], Periodo, []).              % Caso Terminal
organizaEventos([ID|R], Periodo, EventosNoPeriodo) :- horario(ID, _, _, _, _, Periodo),     
                                                     organizaEventos(R, Periodo, [ID|R]); %NOT WORKING YET, RETURNS TRUE
                                                     organizaEventos(R, Periodo, EventosNoPeriodo).


                                    