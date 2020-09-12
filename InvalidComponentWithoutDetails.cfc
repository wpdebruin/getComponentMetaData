component 
{

	public function createDnsFromTemplate( required Domain oDomain, required string DnsTemplateId ) {
		// first retrieve DNS Template (or fail...) We only need this for verification
		var oDnsTemplate = DnsTemplateService.getOrFail( DnsTemplateId );
		// this should not return a dnsDomain, because this is a create
		var oDnsDomain   = findByName( oDomain.getName() );
		// find DNSDomain , if yes, log warning
		if ( isNull( oDnsDomain ) ) {
			// create new dnsDomain
			oDnsDomain = new ( { name : oDomain.getName() } ).save();
		} else {
			// should not be possible, so log warning
			logger.warn( "Can't create DNSDomain #oDnsDomain.getName()#: already present" );
		}
		// retrieve DnsTemplateRecords and create dns for all templateRecords.
		DnsTemplateRecordService
			.listArray( DnsTemplateId, "default", "all" )
			.each( function( templateRecord, index ) {
				// prepare record content, first replacement of placeholders
				var newContent = replaceNoCase(
					TemplateRecord.content,
					"%domain%",
					oDnsDomain.getName()
				);
				newContent = replaceNoCase(
					newContent,
					"%soadate%",
					dateFormat( now(), "yyyymmdd" ) & "00"
				);
				var myRecord = DnsRecordservice.new( {
					domain_id 	 :: oDnsDomain.getId(),
					type         : templateRecord.type,
					content      : newContent,
					ttl          : templateRecord.ttl,
					shortName    : templateRecord.name
				} );
				if ( templateRecord.type eq "MX" ) {
					myRecord.setPrio( templateRecord.prio );
				}
				myRecord.save();
			} );
		// update masterdomain
		oDomain.setDnsEnabled( true ).save();
		MessagingService.sendDnsCreated( oDnsDomain );
		return oDnsDomain;
	}
}