unit DN.ExpertService.Intf;

interface

type
  IDNExpertService = interface
    ['{9F477190-8420-450D-BBE8-02A63AE5D1DD}']
    function RegisterExpert(const AExpert: string; ALoad: Boolean = False): Boolean;
    function UnregisterExpert(const AExpert: string; AUnload: Boolean = False): Boolean;
  end;

implementation

end.
