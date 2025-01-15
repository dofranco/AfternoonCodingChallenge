trigger ContactEmailDomainValidation on Contact (before insert, before update) {
    switch on Trigger.operationType{
        when BEFORE_INSERT{
            ContactHelper.DomainValidation(Trigger.new);
        } when BEFORE_UPDATE {
            ContactHelper.DomainValidation(Trigger.new);
        }
    }
}