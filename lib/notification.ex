defmodule Notification do
  # Attraverso "start" lanciamo il modulo in background
  # funzione bypassabile chiamando spawn direttamente da riga di comando.
  def start do
    # __MODULE__ si riferisce al modulo attuale un alterego del classico this.
    # con :init ci si riferisce all'atom init che in questo caso rappresenta la nostra funzione init
    # l'ultimo valore è una lista che viene passata come argomento ad init. Notare che in questo progetto faremo uso
    # del pattern matching e come primo argomento che passiamo ad init abbiamo una tupla, il primo valore della tupla
    # rappresenta la count dei messaggi e come secondo valore abbiamo la lista dei messaggi ricevuti, siccome stiamo
    # lanciando per la prima volta il message logger il counter è 0 e la lista è vuota.
    spawn(__MODULE__, :init, [{0, []}])
  end

  def init(tupla) do
    # in init possiamo inizializzare tutte le variabili necessarie. In questo caso passiamo subito al lancio di
    # messageLogger che a sua volta richiamera se stesso per rimanere sempre in ascolto.
    messageLogger(tupla)
  end

  # messageLogger è la funzione principale, tutti i dati vengono resi disponibili attraverso l'uso del pattern matching
  # la funzione si richiama continuamente per poter rimanere continuamente in ascolto. Anche i messaggi che arrivano
  # richiamano la sezione corretta grazie al pattern matching. nella sezione {:notice} invece di IO.puts è stato usato
  # IO.inspect perchè maggiormente indicato per stampare le liste.
  def messageLogger({count, messages}) do
    new_tupla = receive do
      {:log, mess} ->
        list = List.insert_at(messages, -1, mess)
        {count + 1, list}
      {:stats} ->
        if count == 1 do
          IO.puts "Hai #{count} messaggio!"
        else
          IO.puts "Hai #{count} messaggi!"
        end
        {count, messages}
      {:notice} ->
        IO.inspect messages, label: "Ecco i messaggi"
        {0, []}
    end
    messageLogger(new_tupla)
  end
end
