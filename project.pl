% 106537 Francisco Fernandes
:- set_prolog_flag(answer_write_options,[max_depth(0)]). % para listas completas
:- ['dados.pl'], ['keywords.pl']. % ficheiros a importar.

% Qualidade dos Dados

eventosSemSalas(EventosSemSala) :- setof(ID, evento(ID,_,_,_,_), EventosSemSala).