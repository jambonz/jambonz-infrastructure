/* SQLEditor (MySQL (2))*/

SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS account_static_ips;

DROP TABLE IF EXISTS account_limits;

DROP TABLE IF EXISTS account_products;

DROP TABLE IF EXISTS account_subscriptions;

DROP TABLE IF EXISTS beta_invite_codes;

DROP TABLE IF EXISTS call_routes;

DROP TABLE IF EXISTS dns_records;

DROP TABLE IF EXISTS lcr_carrier_set_entry;

DROP TABLE IF EXISTS lcr_routes;

DROP TABLE IF EXISTS password_settings;

DROP TABLE IF EXISTS user_permissions;

DROP TABLE IF EXISTS permissions;

DROP TABLE IF EXISTS predefined_sip_gateways;

DROP TABLE IF EXISTS predefined_smpp_gateways;

DROP TABLE IF EXISTS predefined_carriers;

DROP TABLE IF EXISTS account_offers;

DROP TABLE IF EXISTS products;

DROP TABLE IF EXISTS schema_version;

DROP TABLE IF EXISTS api_keys;

DROP TABLE IF EXISTS sbc_addresses;

DROP TABLE IF EXISTS ms_teams_tenants;

DROP TABLE IF EXISTS service_provider_limits;

DROP TABLE IF EXISTS signup_history;

DROP TABLE IF EXISTS smpp_addresses;

DROP TABLE IF EXISTS speech_credentials;

DROP TABLE IF EXISTS users;

DROP TABLE IF EXISTS smpp_gateways;

DROP TABLE IF EXISTS phone_numbers;

DROP TABLE IF EXISTS sip_gateways;

DROP TABLE IF EXISTS voip_carriers;

DROP TABLE IF EXISTS accounts;

DROP TABLE IF EXISTS applications;

DROP TABLE IF EXISTS service_providers;

DROP TABLE IF EXISTS webhooks;

CREATE TABLE account_static_ips
(
account_static_ip_sid CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36) NOT NULL,
public_ipv4 VARCHAR(16) NOT NULL UNIQUE ,
private_ipv4 VARBINARY(16) NOT NULL UNIQUE ,
PRIMARY KEY (account_static_ip_sid)
);

CREATE TABLE account_limits
(
account_limits_sid CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36) NOT NULL,
category ENUM('api_rate','voice_call_session', 'device','voice_call_minutes','voice_call_session_license', 'voice_call_minutes_license') NOT NULL,
quantity INTEGER NOT NULL,
PRIMARY KEY (account_limits_sid)
);

CREATE TABLE account_subscriptions
(
account_subscription_sid CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36) NOT NULL,
pending BOOLEAN NOT NULL DEFAULT false,
effective_start_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
effective_end_date DATETIME,
change_reason VARCHAR(255),
stripe_subscription_id VARCHAR(56),
stripe_payment_method_id VARCHAR(56),
stripe_statement_descriptor VARCHAR(255),
last4 VARCHAR(512),
exp_month INTEGER,
exp_year INTEGER,
card_type VARCHAR(16),
pending_reason VARBINARY(52),
PRIMARY KEY (account_subscription_sid)
);

CREATE TABLE beta_invite_codes
(
invite_code CHAR(6) NOT NULL UNIQUE ,
in_use BOOLEAN NOT NULL DEFAULT false,
PRIMARY KEY (invite_code)
);

CREATE TABLE call_routes
(
call_route_sid CHAR(36) NOT NULL UNIQUE ,
priority INTEGER NOT NULL,
account_sid CHAR(36) NOT NULL,
regex VARCHAR(255) NOT NULL,
application_sid CHAR(36) NOT NULL,
PRIMARY KEY (call_route_sid)
) COMMENT='a regex-based pattern match for call routing';

CREATE TABLE dns_records
(
dns_record_sid CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36) NOT NULL,
record_type VARCHAR(6) NOT NULL,
record_id INTEGER NOT NULL,
PRIMARY KEY (dns_record_sid)
);

CREATE TABLE lcr_routes
(
lcr_route_sid CHAR(36),
regex VARCHAR(32) NOT NULL COMMENT 'regex-based pattern match against dialed number, used for LCR routing of PSTN calls',
description VARCHAR(1024),
priority INTEGER NOT NULL UNIQUE  COMMENT 'lower priority routes are attempted first',
PRIMARY KEY (lcr_route_sid)
) COMMENT='Least cost routing table';

CREATE TABLE password_settings
(
min_password_length INTEGER NOT NULL DEFAULT 8,
require_digit BOOLEAN NOT NULL DEFAULT false,
require_special_character BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE permissions
(
permission_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(32) NOT NULL UNIQUE ,
description VARCHAR(255),
PRIMARY KEY (permission_sid)
);

CREATE TABLE predefined_carriers
(
predefined_carrier_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(64) NOT NULL,
requires_static_ip BOOLEAN NOT NULL DEFAULT false,
e164_leading_plus BOOLEAN NOT NULL DEFAULT false COMMENT 'if true, a leading plus should be prepended to outbound phone numbers',
requires_register BOOLEAN NOT NULL DEFAULT false,
register_username VARCHAR(64),
register_sip_realm VARCHAR(64),
register_password VARCHAR(64),
tech_prefix VARCHAR(16) COMMENT 'tech prefix to prepend to outbound calls to this carrier',
inbound_auth_username VARCHAR(64),
inbound_auth_password VARCHAR(64),
diversion VARCHAR(32),
PRIMARY KEY (predefined_carrier_sid)
);

CREATE TABLE predefined_sip_gateways
(
predefined_sip_gateway_sid CHAR(36) NOT NULL UNIQUE ,
ipv4 VARCHAR(128) NOT NULL COMMENT 'ip address or DNS name of the gateway.  For gateways providing inbound calling service, ip address is required.',
port INTEGER NOT NULL DEFAULT 5060 COMMENT 'sip signaling port',
inbound BOOLEAN NOT NULL COMMENT 'if true, whitelist this IP to allow inbound calls from the gateway',
outbound BOOLEAN NOT NULL COMMENT 'if true, include in least-cost routing when placing calls to the PSTN',
netmask INTEGER NOT NULL DEFAULT 32,
predefined_carrier_sid CHAR(36) NOT NULL,
PRIMARY KEY (predefined_sip_gateway_sid)
);

CREATE TABLE predefined_smpp_gateways
(
predefined_smpp_gateway_sid CHAR(36) NOT NULL UNIQUE ,
ipv4 VARCHAR(128) NOT NULL COMMENT 'ip address or DNS name of the gateway. ',
port INTEGER NOT NULL DEFAULT 2775 COMMENT 'smpp signaling port',
inbound BOOLEAN NOT NULL COMMENT 'if true, whitelist this IP to allow inbound SMS from the gateway',
outbound BOOLEAN NOT NULL COMMENT 'i',
netmask INTEGER NOT NULL DEFAULT 32,
is_primary BOOLEAN NOT NULL DEFAULT 1,
use_tls BOOLEAN DEFAULT 0,
predefined_carrier_sid CHAR(36) NOT NULL,
PRIMARY KEY (predefined_smpp_gateway_sid)
);

CREATE TABLE products
(
product_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(32) NOT NULL,
category ENUM('api_rate','voice_call_session', 'device') NOT NULL,
PRIMARY KEY (product_sid)
);

CREATE TABLE account_products
(
account_product_sid CHAR(36) NOT NULL UNIQUE ,
account_subscription_sid CHAR(36) NOT NULL,
product_sid CHAR(36) NOT NULL,
quantity INTEGER NOT NULL,
PRIMARY KEY (account_product_sid)
);

CREATE TABLE account_offers
(
account_offer_sid CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36) NOT NULL,
product_sid CHAR(36) NOT NULL,
stripe_product_id VARCHAR(56) NOT NULL,
PRIMARY KEY (account_offer_sid)
);

CREATE TABLE schema_version
(
version VARCHAR(16)
);

CREATE TABLE api_keys
(
api_key_sid CHAR(36) NOT NULL UNIQUE ,
token CHAR(36) NOT NULL UNIQUE ,
account_sid CHAR(36),
service_provider_sid CHAR(36),
expires_at TIMESTAMP NULL  DEFAULT NULL,
last_used TIMESTAMP NULL  DEFAULT NULL,
created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (api_key_sid)
) COMMENT='An authorization token that is used to access the REST api';

CREATE TABLE sbc_addresses
(
sbc_address_sid CHAR(36) NOT NULL UNIQUE ,
ipv4 VARCHAR(255) NOT NULL,
port INTEGER NOT NULL DEFAULT 5060,
service_provider_sid CHAR(36),
PRIMARY KEY (sbc_address_sid)
);

CREATE TABLE ms_teams_tenants
(
ms_teams_tenant_sid CHAR(36) NOT NULL UNIQUE ,
service_provider_sid CHAR(36) NOT NULL,
account_sid CHAR(36) NOT NULL,
application_sid CHAR(36),
tenant_fqdn VARCHAR(255) NOT NULL UNIQUE ,
PRIMARY KEY (ms_teams_tenant_sid)
) COMMENT='A Microsoft Teams customer tenant';

CREATE TABLE service_provider_limits
(
service_provider_limits_sid CHAR(36) NOT NULL UNIQUE ,
service_provider_sid CHAR(36) NOT NULL,
category ENUM('api_rate','voice_call_session', 'device','voice_call_minutes','voice_call_session_license', 'voice_call_minutes_license') NOT NULL,
quantity INTEGER NOT NULL,
PRIMARY KEY (service_provider_limits_sid)
);

CREATE TABLE signup_history
(
email VARCHAR(255) NOT NULL,
name VARCHAR(255),
signed_up_at DATETIME DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (email)
);

CREATE TABLE smpp_addresses
(
smpp_address_sid CHAR(36) NOT NULL UNIQUE ,
ipv4 VARCHAR(255) NOT NULL,
port INTEGER NOT NULL DEFAULT 5060,
use_tls BOOLEAN NOT NULL DEFAULT 0,
is_primary BOOLEAN NOT NULL DEFAULT 1,
service_provider_sid CHAR(36),
PRIMARY KEY (smpp_address_sid)
);

CREATE TABLE speech_credentials
(
speech_credential_sid CHAR(36) NOT NULL UNIQUE ,
service_provider_sid CHAR(36),
account_sid CHAR(36),
vendor VARCHAR(32) NOT NULL,
credential VARCHAR(8192) NOT NULL,
use_for_tts BOOLEAN DEFAULT true,
use_for_stt BOOLEAN DEFAULT true,
last_used DATETIME,
last_tested DATETIME,
tts_tested_ok BOOLEAN,
stt_tested_ok BOOLEAN,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (speech_credential_sid)
);

CREATE TABLE users
(
user_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL,
pending_email VARCHAR(255),
phone VARCHAR(20) UNIQUE ,
hashed_password VARCHAR(1024),
account_sid CHAR(36),
service_provider_sid CHAR(36),
force_change BOOLEAN NOT NULL DEFAULT FALSE,
provider VARCHAR(255) NOT NULL,
provider_userid VARCHAR(255),
scope VARCHAR(16) NOT NULL DEFAULT 'read-write',
phone_activation_code VARCHAR(16),
email_activation_code VARCHAR(16),
email_validated BOOLEAN NOT NULL DEFAULT false,
phone_validated BOOLEAN NOT NULL DEFAULT false,
email_content_opt_out BOOLEAN NOT NULL DEFAULT false,
is_active BOOLEAN NOT NULL DEFAULT true,
PRIMARY KEY (user_sid)
);

CREATE TABLE voip_carriers
(
voip_carrier_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(64) NOT NULL,
description VARCHAR(255),
account_sid CHAR(36) COMMENT 'if provided, indicates this entity represents a sip trunk that is associated with a specific account',
service_provider_sid CHAR(36),
application_sid CHAR(36) COMMENT 'If provided, all incoming calls from this source will be routed to the associated application',
e164_leading_plus BOOLEAN NOT NULL DEFAULT false COMMENT 'if true, a leading plus should be prepended to outbound phone numbers',
requires_register BOOLEAN NOT NULL DEFAULT false,
register_username VARCHAR(64),
register_sip_realm VARCHAR(64),
register_password VARCHAR(64),
tech_prefix VARCHAR(16) COMMENT 'tech prefix to prepend to outbound calls to this carrier',
inbound_auth_username VARCHAR(64),
inbound_auth_password VARCHAR(64),
diversion VARCHAR(32),
is_active BOOLEAN NOT NULL DEFAULT true,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
smpp_system_id VARCHAR(255),
smpp_password VARCHAR(64),
smpp_enquire_link_interval INTEGER DEFAULT 0,
smpp_inbound_system_id VARCHAR(255),
smpp_inbound_password VARCHAR(64),
register_from_user VARCHAR(128),
register_from_domain VARCHAR(255),
register_public_ip_in_contact BOOLEAN NOT NULL DEFAULT false,
PRIMARY KEY (voip_carrier_sid)
) COMMENT='A Carrier or customer PBX that can send or receive calls';

CREATE TABLE user_permissions
(
user_permissions_sid CHAR(36) NOT NULL UNIQUE ,
user_sid CHAR(36) NOT NULL,
permission_sid CHAR(36) NOT NULL,
PRIMARY KEY (user_permissions_sid)
);

CREATE TABLE smpp_gateways
(
smpp_gateway_sid CHAR(36) NOT NULL UNIQUE ,
ipv4 VARCHAR(128) NOT NULL,
port INTEGER NOT NULL DEFAULT 2775,
netmask INTEGER NOT NULL DEFAULT 32,
is_primary BOOLEAN NOT NULL DEFAULT 1,
inbound BOOLEAN NOT NULL DEFAULT 0 COMMENT 'if true, whitelist this IP to allow inbound calls from the gateway',
outbound BOOLEAN NOT NULL DEFAULT 1 COMMENT 'if true, include in least-cost routing when placing calls to the PSTN',
use_tls BOOLEAN DEFAULT 0,
voip_carrier_sid CHAR(36) NOT NULL,
PRIMARY KEY (smpp_gateway_sid)
);

CREATE TABLE phone_numbers
(
phone_number_sid CHAR(36) UNIQUE ,
number VARCHAR(132) NOT NULL UNIQUE ,
voip_carrier_sid CHAR(36),
account_sid CHAR(36),
application_sid CHAR(36),
service_provider_sid CHAR(36) COMMENT 'if not null, this number is a test number for the associated service provider',
PRIMARY KEY (phone_number_sid)
) COMMENT='A phone number that has been assigned to an account';

CREATE TABLE sip_gateways
(
sip_gateway_sid CHAR(36),
ipv4 VARCHAR(128) NOT NULL COMMENT 'ip address or DNS name of the gateway.  For gateways providing inbound calling service, ip address is required.',
netmask INTEGER NOT NULL DEFAULT 32,
port INTEGER NOT NULL DEFAULT 5060 COMMENT 'sip signaling port',
inbound BOOLEAN NOT NULL COMMENT 'if true, whitelist this IP to allow inbound calls from the gateway',
outbound BOOLEAN NOT NULL COMMENT 'if true, include in least-cost routing when placing calls to the PSTN',
voip_carrier_sid CHAR(36) NOT NULL,
is_active BOOLEAN NOT NULL DEFAULT 1,
PRIMARY KEY (sip_gateway_sid)
) COMMENT='A whitelisted sip gateway used for origination/termination';

CREATE TABLE lcr_carrier_set_entry
(
lcr_carrier_set_entry_sid CHAR(36),
workload INTEGER NOT NULL DEFAULT 1 COMMENT 'represents a proportion of traffic to send through the associated carrier; can be used for load balancing traffic across carriers with a common priority for a destination',
lcr_route_sid CHAR(36) NOT NULL,
voip_carrier_sid CHAR(36) NOT NULL,
priority INTEGER NOT NULL DEFAULT 0 COMMENT 'lower priority carriers are attempted first',
PRIMARY KEY (lcr_carrier_set_entry_sid)
) COMMENT='An entry in the LCR routing list';

CREATE TABLE webhooks
(
webhook_sid CHAR(36) NOT NULL UNIQUE ,
url VARCHAR(1024) NOT NULL,
method ENUM("GET","POST") NOT NULL DEFAULT 'POST',
username VARCHAR(255),
password VARCHAR(255),
PRIMARY KEY (webhook_sid)
) COMMENT='An HTTP callback';

CREATE TABLE applications
(
application_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(64) NOT NULL,
service_provider_sid CHAR(36) COMMENT 'if non-null, this application is a test application that can be used by any account under the associated service provider',
account_sid CHAR(36) COMMENT 'account that this application belongs to (if null, this is a service provider test application)',
call_hook_sid CHAR(36) COMMENT 'webhook to call for inbound calls ',
call_status_hook_sid CHAR(36) COMMENT 'webhook to call for call status events',
messaging_hook_sid CHAR(36) COMMENT 'webhook to call for inbound SMS/MMS ',
app_json TEXT,
speech_synthesis_vendor VARCHAR(64) NOT NULL DEFAULT 'google',
speech_synthesis_language VARCHAR(12) NOT NULL DEFAULT 'en-US',
speech_synthesis_voice VARCHAR(64),
speech_recognizer_vendor VARCHAR(64) NOT NULL DEFAULT 'google',
speech_recognizer_language VARCHAR(64) NOT NULL DEFAULT 'en-US',
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (application_sid)
) COMMENT='A defined set of behaviors to be applied to phone calls ';

CREATE TABLE service_providers
(
service_provider_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(64) NOT NULL UNIQUE ,
description VARCHAR(255),
root_domain VARCHAR(128) UNIQUE ,
registration_hook_sid CHAR(36),
ms_teams_fqdn VARCHAR(255),
PRIMARY KEY (service_provider_sid)
) COMMENT='A partition of the platform used by one service provider';

CREATE TABLE accounts
(
account_sid CHAR(36) NOT NULL UNIQUE ,
name VARCHAR(64) NOT NULL,
sip_realm VARCHAR(132) UNIQUE  COMMENT 'sip domain that will be used for devices registering under this account',
service_provider_sid CHAR(36) NOT NULL COMMENT 'service provider that owns the customer relationship with this account',
registration_hook_sid CHAR(36) COMMENT 'webhook to call when devices underr this account attempt to register',
queue_event_hook_sid CHAR(36),
device_calling_application_sid CHAR(36) COMMENT 'application to use for outbound calling from an account',
is_active BOOLEAN NOT NULL DEFAULT true,
created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
plan_type ENUM('trial','free','paid') NOT NULL DEFAULT 'trial',
stripe_customer_id VARCHAR(56),
webhook_secret VARCHAR(36) NOT NULL,
disable_cdrs BOOLEAN NOT NULL DEFAULT 0,
trial_end_date DATETIME,
deactivated_reason VARCHAR(255),
device_to_call_ratio INTEGER NOT NULL DEFAULT 5,
subspace_client_id VARCHAR(255),
subspace_client_secret VARCHAR(255),
subspace_sip_teleport_id VARCHAR(255),
subspace_sip_teleport_destinations VARCHAR(255),
siprec_hook_sid CHAR(36),
PRIMARY KEY (account_sid)
) COMMENT='An enterprise that uses the platform for comm services';

CREATE INDEX account_static_ip_sid_idx ON account_static_ips (account_static_ip_sid);
CREATE INDEX account_sid_idx ON account_static_ips (account_sid);
ALTER TABLE account_static_ips ADD FOREIGN KEY account_sid_idxfk (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX account_sid_idx ON account_limits (account_sid);
ALTER TABLE account_limits ADD FOREIGN KEY account_sid_idxfk_1 (account_sid) REFERENCES accounts (account_sid) ON DELETE CASCADE;

CREATE INDEX account_subscription_sid_idx ON account_subscriptions (account_subscription_sid);
CREATE INDEX account_sid_idx ON account_subscriptions (account_sid);
ALTER TABLE account_subscriptions ADD FOREIGN KEY account_sid_idxfk_2 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX invite_code_idx ON beta_invite_codes (invite_code);
CREATE INDEX call_route_sid_idx ON call_routes (call_route_sid);
ALTER TABLE call_routes ADD FOREIGN KEY account_sid_idxfk_3 (account_sid) REFERENCES accounts (account_sid);

ALTER TABLE call_routes ADD FOREIGN KEY application_sid_idxfk (application_sid) REFERENCES applications (application_sid);

CREATE INDEX dns_record_sid_idx ON dns_records (dns_record_sid);
ALTER TABLE dns_records ADD FOREIGN KEY account_sid_idxfk_4 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX permission_sid_idx ON permissions (permission_sid);
CREATE INDEX predefined_carrier_sid_idx ON predefined_carriers (predefined_carrier_sid);
CREATE INDEX predefined_sip_gateway_sid_idx ON predefined_sip_gateways (predefined_sip_gateway_sid);
CREATE INDEX predefined_carrier_sid_idx ON predefined_sip_gateways (predefined_carrier_sid);
ALTER TABLE predefined_sip_gateways ADD FOREIGN KEY predefined_carrier_sid_idxfk (predefined_carrier_sid) REFERENCES predefined_carriers (predefined_carrier_sid);

CREATE INDEX predefined_smpp_gateway_sid_idx ON predefined_smpp_gateways (predefined_smpp_gateway_sid);
CREATE INDEX predefined_carrier_sid_idx ON predefined_smpp_gateways (predefined_carrier_sid);
ALTER TABLE predefined_smpp_gateways ADD FOREIGN KEY predefined_carrier_sid_idxfk_1 (predefined_carrier_sid) REFERENCES predefined_carriers (predefined_carrier_sid);

CREATE INDEX product_sid_idx ON products (product_sid);
CREATE INDEX account_product_sid_idx ON account_products (account_product_sid);
CREATE INDEX account_subscription_sid_idx ON account_products (account_subscription_sid);
ALTER TABLE account_products ADD FOREIGN KEY account_subscription_sid_idxfk (account_subscription_sid) REFERENCES account_subscriptions (account_subscription_sid);

ALTER TABLE account_products ADD FOREIGN KEY product_sid_idxfk (product_sid) REFERENCES products (product_sid);

CREATE INDEX account_offer_sid_idx ON account_offers (account_offer_sid);
CREATE INDEX account_sid_idx ON account_offers (account_sid);
ALTER TABLE account_offers ADD FOREIGN KEY account_sid_idxfk_5 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX product_sid_idx ON account_offers (product_sid);
ALTER TABLE account_offers ADD FOREIGN KEY product_sid_idxfk_1 (product_sid) REFERENCES products (product_sid);

CREATE INDEX api_key_sid_idx ON api_keys (api_key_sid);
CREATE INDEX account_sid_idx ON api_keys (account_sid);
ALTER TABLE api_keys ADD FOREIGN KEY account_sid_idxfk_6 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX service_provider_sid_idx ON api_keys (service_provider_sid);
ALTER TABLE api_keys ADD FOREIGN KEY service_provider_sid_idxfk (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX sbc_addresses_idx_host_port ON sbc_addresses (ipv4,port);

CREATE INDEX sbc_address_sid_idx ON sbc_addresses (sbc_address_sid);
CREATE INDEX service_provider_sid_idx ON sbc_addresses (service_provider_sid);
ALTER TABLE sbc_addresses ADD FOREIGN KEY service_provider_sid_idxfk_1 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX ms_teams_tenant_sid_idx ON ms_teams_tenants (ms_teams_tenant_sid);
ALTER TABLE ms_teams_tenants ADD FOREIGN KEY service_provider_sid_idxfk_2 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

ALTER TABLE ms_teams_tenants ADD FOREIGN KEY account_sid_idxfk_7 (account_sid) REFERENCES accounts (account_sid);

ALTER TABLE ms_teams_tenants ADD FOREIGN KEY application_sid_idxfk_1 (application_sid) REFERENCES applications (application_sid);

CREATE INDEX tenant_fqdn_idx ON ms_teams_tenants (tenant_fqdn);
CREATE INDEX service_provider_sid_idx ON service_provider_limits (service_provider_sid);
ALTER TABLE service_provider_limits ADD FOREIGN KEY service_provider_sid_idxfk_3 (service_provider_sid) REFERENCES service_providers (service_provider_sid) ON DELETE CASCADE;

CREATE INDEX email_idx ON signup_history (email);
CREATE INDEX smpp_address_sid_idx ON smpp_addresses (smpp_address_sid);
CREATE INDEX service_provider_sid_idx ON smpp_addresses (service_provider_sid);
ALTER TABLE smpp_addresses ADD FOREIGN KEY service_provider_sid_idxfk_4 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE UNIQUE INDEX speech_credentials_idx_1 ON speech_credentials (vendor,account_sid);

CREATE INDEX speech_credential_sid_idx ON speech_credentials (speech_credential_sid);
CREATE INDEX service_provider_sid_idx ON speech_credentials (service_provider_sid);
ALTER TABLE speech_credentials ADD FOREIGN KEY service_provider_sid_idxfk_5 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX account_sid_idx ON speech_credentials (account_sid);
ALTER TABLE speech_credentials ADD FOREIGN KEY account_sid_idxfk_8 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX user_sid_idx ON users (user_sid);
CREATE INDEX email_idx ON users (email);
CREATE INDEX phone_idx ON users (phone);
CREATE INDEX account_sid_idx ON users (account_sid);
ALTER TABLE users ADD FOREIGN KEY account_sid_idxfk_9 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX service_provider_sid_idx ON users (service_provider_sid);
ALTER TABLE users ADD FOREIGN KEY service_provider_sid_idxfk_6 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX email_activation_code_idx ON users (email_activation_code);
CREATE INDEX voip_carrier_sid_idx ON voip_carriers (voip_carrier_sid);
CREATE INDEX account_sid_idx ON voip_carriers (account_sid);
ALTER TABLE voip_carriers ADD FOREIGN KEY account_sid_idxfk_10 (account_sid) REFERENCES accounts (account_sid);

CREATE INDEX service_provider_sid_idx ON voip_carriers (service_provider_sid);
ALTER TABLE voip_carriers ADD FOREIGN KEY service_provider_sid_idxfk_7 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

ALTER TABLE voip_carriers ADD FOREIGN KEY application_sid_idxfk_2 (application_sid) REFERENCES applications (application_sid);

CREATE INDEX user_permissions_sid_idx ON user_permissions (user_permissions_sid);
CREATE INDEX user_sid_idx ON user_permissions (user_sid);
ALTER TABLE user_permissions ADD FOREIGN KEY user_sid_idxfk (user_sid) REFERENCES users (user_sid) ON DELETE CASCADE;

ALTER TABLE user_permissions ADD FOREIGN KEY permission_sid_idxfk (permission_sid) REFERENCES permissions (permission_sid);

CREATE INDEX smpp_gateway_sid_idx ON smpp_gateways (smpp_gateway_sid);
CREATE INDEX voip_carrier_sid_idx ON smpp_gateways (voip_carrier_sid);
ALTER TABLE smpp_gateways ADD FOREIGN KEY voip_carrier_sid_idxfk (voip_carrier_sid) REFERENCES voip_carriers (voip_carrier_sid);

CREATE INDEX phone_number_sid_idx ON phone_numbers (phone_number_sid);
CREATE INDEX number_idx ON phone_numbers (number);
CREATE INDEX voip_carrier_sid_idx ON phone_numbers (voip_carrier_sid);
ALTER TABLE phone_numbers ADD FOREIGN KEY voip_carrier_sid_idxfk_1 (voip_carrier_sid) REFERENCES voip_carriers (voip_carrier_sid);

ALTER TABLE phone_numbers ADD FOREIGN KEY account_sid_idxfk_11 (account_sid) REFERENCES accounts (account_sid);

ALTER TABLE phone_numbers ADD FOREIGN KEY application_sid_idxfk_3 (application_sid) REFERENCES applications (application_sid);

CREATE INDEX service_provider_sid_idx ON phone_numbers (service_provider_sid);
ALTER TABLE phone_numbers ADD FOREIGN KEY service_provider_sid_idxfk_8 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX sip_gateway_idx_hostport ON sip_gateways (ipv4,port);

CREATE INDEX voip_carrier_sid_idx ON sip_gateways (voip_carrier_sid);
ALTER TABLE sip_gateways ADD FOREIGN KEY voip_carrier_sid_idxfk_2 (voip_carrier_sid) REFERENCES voip_carriers (voip_carrier_sid);

ALTER TABLE lcr_carrier_set_entry ADD FOREIGN KEY lcr_route_sid_idxfk (lcr_route_sid) REFERENCES lcr_routes (lcr_route_sid);

ALTER TABLE lcr_carrier_set_entry ADD FOREIGN KEY voip_carrier_sid_idxfk_3 (voip_carrier_sid) REFERENCES voip_carriers (voip_carrier_sid);

CREATE INDEX webhook_sid_idx ON webhooks (webhook_sid);
CREATE UNIQUE INDEX applications_idx_name ON applications (account_sid,name);

CREATE INDEX application_sid_idx ON applications (application_sid);
CREATE INDEX service_provider_sid_idx ON applications (service_provider_sid);
ALTER TABLE applications ADD FOREIGN KEY service_provider_sid_idxfk_9 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

CREATE INDEX account_sid_idx ON applications (account_sid);
ALTER TABLE applications ADD FOREIGN KEY account_sid_idxfk_12 (account_sid) REFERENCES accounts (account_sid);

ALTER TABLE applications ADD FOREIGN KEY call_hook_sid_idxfk (call_hook_sid) REFERENCES webhooks (webhook_sid);

ALTER TABLE applications ADD FOREIGN KEY call_status_hook_sid_idxfk (call_status_hook_sid) REFERENCES webhooks (webhook_sid);

ALTER TABLE applications ADD FOREIGN KEY messaging_hook_sid_idxfk (messaging_hook_sid) REFERENCES webhooks (webhook_sid);

CREATE INDEX service_provider_sid_idx ON service_providers (service_provider_sid);
CREATE INDEX name_idx ON service_providers (name);
CREATE INDEX root_domain_idx ON service_providers (root_domain);
ALTER TABLE service_providers ADD FOREIGN KEY registration_hook_sid_idxfk (registration_hook_sid) REFERENCES webhooks (webhook_sid);

CREATE INDEX account_sid_idx ON accounts (account_sid);
CREATE INDEX sip_realm_idx ON accounts (sip_realm);
CREATE INDEX service_provider_sid_idx ON accounts (service_provider_sid);
ALTER TABLE accounts ADD FOREIGN KEY service_provider_sid_idxfk_10 (service_provider_sid) REFERENCES service_providers (service_provider_sid);

ALTER TABLE accounts ADD FOREIGN KEY registration_hook_sid_idxfk_1 (registration_hook_sid) REFERENCES webhooks (webhook_sid);

ALTER TABLE accounts ADD FOREIGN KEY queue_event_hook_sid_idxfk (queue_event_hook_sid) REFERENCES webhooks (webhook_sid);

ALTER TABLE accounts ADD FOREIGN KEY device_calling_application_sid_idxfk (device_calling_application_sid) REFERENCES applications (application_sid);

ALTER TABLE accounts ADD FOREIGN KEY siprec_hook_sid_idxfk (siprec_hook_sid) REFERENCES applications (application_sid);

-- create standard permissions 
insert into permissions (permission_sid, name, description)
values 
('ffbc342a-546a-11ed-bdc3-0242ac120002', 'VIEW_ONLY', 'Can view data but not make changes'),
('ffbc3a10-546a-11ed-bdc3-0242ac120002', 'PROVISION_SERVICES', 'Can provision services'),
('ffbc3c5e-546a-11ed-bdc3-0242ac120002', 'PROVISION_USERS', 'Can provision users');

insert into sbc_addresses (sbc_address_sid, ipv4, port) 
values('f6567ae1-bf97-49af-8931-ca014b689995', '52.55.111.178', 5060);
insert into sbc_addresses (sbc_address_sid, ipv4, port) 
values('de5ed2f1-bccd-4600-a95e-cef46e9a3a4f', '3.34.102.122', 5060);
insert into smpp_addresses (smpp_address_sid, ipv4, port, use_tls, is_primary) 
values('de5ed2f1-bccd-4600-a95e-cef46e9a3a4f', '34.197.99.29', 2775, 0, 1);
insert into smpp_addresses (smpp_address_sid, ipv4, port, use_tls, is_primary) 
values('049078a0', '3.209.58.102', 3550, 1, 1);

-- create one service provider and account
insert into api_keys (api_key_sid, token) 
values ('3f35518f-5a0d-4c2e-90a5-2407bb3b36f0', '38700987-c7a4-4685-a5bb-af378f9734de');

-- create one service provider and one account
insert into service_providers (service_provider_sid, name, root_domain) 
values ('2708b1b3-2736-40ea-b502-c53d8396247f', 'default service provider', 'sip.jambonz.us');

insert into accounts (account_sid, service_provider_sid, name, webhook_secret) 
values ('9351f46a-678c-43f5-b8a6-d4eb58d131af','2708b1b3-2736-40ea-b502-c53d8396247f', 'default account', 'wh_secret_cJqgtMDPzDhhnjmaJH6Mtk');

-- create two applications
insert into webhooks(webhook_sid, url, method)
values 
('84e3db00-b172-4e46-b54b-a503fdb19e4a', 'https://public-apps.jambonz.us/call-status', 'POST'),
('d31568d0-b193-4a05-8ff6-778369bc6efe', 'https://public-apps.jambonz.us/hello-world', 'POST'),
('81844b05-714d-4295-8bf3-3b0640a4bf02', 'https://public-apps.jambonz.us/dial-time', 'POST');

insert into applications (application_sid, account_sid, name, call_hook_sid, call_status_hook_sid, speech_synthesis_vendor, speech_synthesis_language, speech_synthesis_voice, speech_recognizer_vendor, speech_recognizer_language)
VALUES
('7087fe50-8acb-4f3b-b820-97b573723aab', '9351f46a-678c-43f5-b8a6-d4eb58d131af', 'hello world', 'd31568d0-b193-4a05-8ff6-778369bc6efe', '84e3db00-b172-4e46-b54b-a503fdb19e4a', 'google', 'en-US', 'en-US-Wavenet-C', 'google', 'en-US'),
('4ca2fb6a-8636-4f2e-96ff-8966c5e26f8e', '9351f46a-678c-43f5-b8a6-d4eb58d131af', 'dial time', '81844b05-714d-4295-8bf3-3b0640a4bf02', '84e3db00-b172-4e46-b54b-a503fdb19e4a', 'google', 'en-US', 'en-US-Wavenet-C', 'google', 'en-US');

-- create our products
insert into products (product_sid, name, category)
values
('c4403cdb-8e75-4b27-9726-7d8315e3216d', 'concurrent call session', 'voice_call_session'),
('2c815913-5c26-4004-b748-183b459329df', 'registered device', 'device'),
('35a9fb10-233d-4eb9-aada-78de5814d680', 'api call', 'api_rate');

-- create predefined carriers
insert into predefined_carriers (predefined_carrier_sid, name, requires_static_ip, e164_leading_plus, 
requires_register, register_username, register_password, 
register_sip_realm, tech_prefix, inbound_auth_username, inbound_auth_password, diversion)
VALUES
('17479288-bb9f-421a-89d1-f4ac57af1dca', 'TelecomsXChange', 0, 0, 0, NULL, NULL, NULL, 'your-tech-prefix', NULL, NULL, NULL),
('7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', 'Twilio', 0, 1, 0, '<your-twilio-credential-username>', '<your-twilio-credential-password>', NULL, NULL, NULL, NULL, NULL),
('032d90d5-39e8-41c0-b807-9c88cffba65c', 'Voxbone', 0, 1, 0, '<your-voxbone-outbound-username>', '<your-voxbone-outbound-password>', NULL, NULL, NULL, NULL, '<your-voxbone-DID>'),
('e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', 'Simwood', 0, 1, 0, '<your-simwood-auth-trunk-username>',  '<your-simwood-auth-trunk-password>', NULL, NULL, NULL, NULL, NULL);

-- TelecomXchange gateways
insert into predefined_sip_gateways (predefined_sip_gateway_sid, predefined_carrier_sid, ipv4, netmask, port, inbound, outbound)
VALUES
('c9c3643e-9a83-4b78-b172-9c09d911bef5', '17479288-bb9f-421a-89d1-f4ac57af1dca', '174.136.44.213', 32, 5060, 1, 0),
('3b5b7fa5-4e61-4423-b921-05c3283b2101', '17479288-bb9f-421a-89d1-f4ac57af1dca', 'sip01.TelecomsXChange.com', 32, 5060, 0, 1);

insert into predefined_smpp_gateways (predefined_smpp_gateway_sid, predefined_carrier_sid, ipv4, netmask, port, inbound, outbound)
VALUES
('9b72467a-cfe3-491f-80bf-652c38e666b9', '17479288-bb9f-421a-89d1-f4ac57af1dca', 'smpp01.telecomsxchange.com', 32, 2776, 0, 1),
('d22883b9-f124-4a89-bab2-4487cf783f64', '17479288-bb9f-421a-89d1-f4ac57af1dca', '174.136.44.11', 32, 2775, 1, 0),
('fdcf7f1e-1f5f-487b-afb3-c0f75ed0aa3d', '17479288-bb9f-421a-89d1-f4ac57af1dca', '174.136.44.213', 32, 2775, 1, 0);

-- twilio gateways
insert into predefined_sip_gateways (predefined_sip_gateway_sid, predefined_carrier_sid, ipv4, netmask, port, inbound, outbound)
VALUES
('d2ccfcb1-9198-4fe9-a0ca-6e49395837c4', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.172.60.0', 30, 5060, 1, 0),
('6b1d0032-4430-41f1-87c6-f22233d394ef', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.244.51.0', 30, 5060, 1, 0),
('0de40217-8bd5-4aa8-a9fd-1994282953c6', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.171.127.192', 30, 5060, 1, 0),
('37bc0b20-b53c-4c31-95a6-f82b1c3713e3', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '35.156.191.128', 30, 5060, 1, 0),
('39791f4e-b612-4882-a37e-e92711a39f3f', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.65.63.192', 30, 5060, 1, 0),
('81a0c8cb-a33e-42da-8f20-99083da6f02f', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.252.254.64', 30, 5060, 1, 0),
('eeeef07a-46b8-4ffe-a4f2-04eb32ca889e', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '54.169.127.128', 30, 5060, 1, 0),
('fbb6c194-4b68-4dff-9b42-52412be1c39e', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '177.71.206.192', 30, 5060, 1, 0),
('3ed1dd12-e1a7-44ff-811a-3cc5dc13dc72', '7d509a18-bbff-4c5d-b21e-b99bf8f8c49a', '<your-domain>.pstn.twilio.com', 32, 5060, 0, 1);

-- voxbone gateways
insert into predefined_sip_gateways (predefined_sip_gateway_sid, predefined_carrier_sid, ipv4, netmask, port, inbound, outbound)
VALUES
('d531c582-2103-42a0-b9f0-f80c215b3ec5', '032d90d5-39e8-41c0-b807-9c88cffba65c', '81.201.83.45', 32, 5060, 1, 0),
('95c888e5-c959-4d92-82c4-8597dddff75e', '032d90d5-39e8-41c0-b807-9c88cffba65c', '81.201.86.45', 32, 5060, 1, 0),
('1de3b2a1-96f0-407a-bcc4-ce371d823a8d', '032d90d5-39e8-41c0-b807-9c88cffba65c', '81.201.82.45', 32, 5060, 1, 0),
('50c1f91a-6080-4495-a241-6bba6e9d9688', '032d90d5-39e8-41c0-b807-9c88cffba65c', '81.201.85.45', 32, 5060, 1, 0),
('e6ebad33-80d5-4dbb-bc6f-a7ae08160cc6', '032d90d5-39e8-41c0-b807-9c88cffba65c', '81.201.84.45', 32, 5060, 1, 0),
('7bae60b3-4237-4baa-a711-30ea3bce19d8', '032d90d5-39e8-41c0-b807-9c88cffba65c', '185.47.148.45', 32, 5060, 1, 0),
('bc933522-18a2-47d8-9ae4-9faa8de4e927', '032d90d5-39e8-41c0-b807-9c88cffba65c', 'outbound.voxbone.com', 32, 5060, 0, 1);

-- simwood gateways
insert into predefined_sip_gateways (predefined_sip_gateway_sid, predefined_carrier_sid, ipv4, netmask, port, inbound, outbound)
VALUES
('91cb050f-9826-4ac9-b736-84a10372a9fe', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', '178.22.139.77', 32, 5060, 1, 0),
('58700fad-98bf-4d31-b61e-888c54911b35', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', '185.63.140.77', 32, 5060, 1, 0),
('d020fd9e-7fdb-4bca-ae0d-e61b38142873', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', '185.63.142.77', 32, 5060, 1, 0),
('38d8520a-527f-4f8e-8456-f9dfca742561', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', '172.86.225.77', 32, 5060, 1, 0),
('834f8b0c-d4c2-4f3e-93d9-cf307995eedd', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', '172.86.225.88', 32, 5060, 1, 0),
('5f431d42-48e4-44ce-a311-d946f0b475b6', 'e6fb301a-1af0-4fb8-a1f6-f65530c6e1c6', 'out.simwood.com', 32, 5060, 0, 1);

-- user
INSERT into users (user_sid, name, email, hashed_password, force_change, provider, email_validated)
VALUES('a9f5599c-037d-452d-a0e6-aff8291d8737', 'admin', 'joe@foo.bar', '$argon2i$v=19$m=4096,t=3,p=1$lyB2Qp2lp9hGoSP83PhSVHakp3lMqTlsAprK8QXMKXg$Md5u5lYqqIQsTXCPRteUxPX/Ukj5I61wkbtEsHH1nXc', 1, 'local', 1);
INSERT into api_keys (api_key_sid, token) VALUES ('102e5696-117f-4707-b217-bb133cfb65dc', '2d78e09b-c2e0-4d30-97f3-24397e749452');
INSERT into user_permissions (user_permissions_sid, user_sid, permission_sid) VALUES 
('5a3e38b5-3188-4936-89c9-fb0df3138b5c','a9f5599c-037d-452d-a0e6-aff8291d8737','ffbc342a-546a-11ed-bdc3-0242ac120002'),
('d85030b0-33e0-429a-80f0-bd706d21c581','a9f5599c-037d-452d-a0e6-aff8291d8737','ffbc3a10-546a-11ed-bdc3-0242ac120002'),
('fd9effa6-5dd0-4adc-bd9d-2a51ca6ef29f','a9f5599c-037d-452d-a0e6-aff8291d8737','ffbc3c5e-546a-11ed-bdc3-0242ac120002');

INSERT into api_keys (api_key_sid, token, account_sid) 
VALUES ('5a3e38b5-3188-4936-89c9-fb0df3138b5c', '5a3e38b5-3188-4936-89c9-fb0df3138b5c', '9351f46a-678c-43f5-b8a6-d4eb58d131af');

SET FOREIGN_KEY_CHECKS=1;