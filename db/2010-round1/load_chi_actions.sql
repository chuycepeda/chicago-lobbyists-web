-- CHICAGO LOBBYIST ACTIONS
DROP TABLE public.chi_actions;
CREATE TABLE public.chi_actions  (
  id             serial NOT NULL,
  agency_id      integer NOT NULL,
  lobbyist_id    integer NOT NULL,
  purpose        varchar(100) NULL,
  administrative boolean NULL,
  legislative    boolean NULL,

  CONSTRAINT chi_actions_pk PRIMARY KEY(id)
);

CREATE INDEX chi_actions_foreign_idx ON chi_actions (agency_id, lobbyist_id);


-- LOAD CHICAGO LOBBYIST ACTIONS
INSERT INTO public.chi_actions (agency_id, lobbyist_id, purpose, administrative, legislative)
SELECT DISTINCT chi_agencies.id, lobbyist.id, agency.action_sought, agency.admin_action, agency.legislative_action
FROM public.lobbyist_agencies agency
  INNER JOIN public.chi_lobbyists lobbyist
  ON agency.first_name = lobbyist.first_name and agency.last_name = lobbyist.last_name

  INNER JOIN public.chi_agencies
  ON agency.agency_code = chi_agencies.code;

