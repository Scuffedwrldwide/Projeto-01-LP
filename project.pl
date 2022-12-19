% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

%organizaEventos([ID|R], P, E) :- horario(ID,_,_,_,_,P)organizaEventos(R,P,[ID|]).