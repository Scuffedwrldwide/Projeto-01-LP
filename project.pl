% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados
eventosSemSalas(EventosSemSala) :-  findall(ID, evento(ID, _, _, _, semSala), EventosSemSala).
%usa maplist no prox.

% Pesquisas Simples
organizaEventos([], Periodo, EventosNoPeriodo) :- true.              % Caso Terminal
organizaEventos([ID|R], Periodo, EventosNoPeriodo) :- horario(ID, _, _, _, _, Periodo),     
                                                     organizaEventos(R, Periodo, [ID|_]); %NOT WORKING YET, RETURNS TRUE
                                                     organizaEventos(R, Periodo, [_]).


                                    