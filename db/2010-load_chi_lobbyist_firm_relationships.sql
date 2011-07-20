-- CHICAGO LOBBYIST CLIENTS
DROP TABLE public.chi_lobbyist_firm_relationships;
CREATE TABLE public.chi_lobbyist_firm_relationships  ( 
  id           	serial NOT NULL,
  lobbyist_id   integer NOT NULL,
  firm_id       integer NOT NULL,
  client_id     integer NOT NULL,

  CONSTRAINT chi_lobbyist_firm_relationships_pk PRIMARY KEY(id),
  CONSTRAINT chi_lobbyist_firm_relationships_unique UNIQUE(lobbyist_id, firm_id, client_id)
);


-- CHICAGO LOBBYIST CLIENTS
INSERT INTO public.chi_lobbyist_firm_relationships(
  lobbyist_id, firm_id, client_id)
SELECT DISTINCT l.id, firm.id, client.id
FROM public.chi_lobbyists l
  INNER JOIN public.lobbyists client
  ON l.first_name = client.first_name and l.last_name = client.last_name

  INNER JOIN public.chi_firms firm
  ON firm.name = client.employer_name;

