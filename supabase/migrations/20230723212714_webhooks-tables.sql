create table "public"."feature_flags" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "org_id" uuid not null,
    "feature" text not null
);


alter table "public"."feature_flags" enable row level security;

create table "public"."webhook_subscriptions" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "webhook_id" bigint not null,
    "event" text not null,
    "payload_type" jsonb not null
);


alter table "public"."webhook_subscriptions" enable row level security;

create table "public"."webhooks" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "is_verified" boolean not null default false,
    "org_id" uuid not null,
    "txt_record" text not null,
    "destination" text not null
);


alter table "public"."webhooks" enable row level security;

CREATE UNIQUE INDEX feature_flags_pkey ON public.feature_flags USING btree (id);

CREATE UNIQUE INDEX webhook_subscriptions_pkey ON public.webhook_subscriptions USING btree (id);

CREATE UNIQUE INDEX webhooks_pkey ON public.webhooks USING btree (id);

alter table "public"."feature_flags" add constraint "feature_flags_pkey" PRIMARY KEY using index "feature_flags_pkey";

alter table "public"."webhook_subscriptions" add constraint "webhook_subscriptions_pkey" PRIMARY KEY using index "webhook_subscriptions_pkey";

alter table "public"."webhooks" add constraint "webhooks_pkey" PRIMARY KEY using index "webhooks_pkey";

alter table "public"."feature_flags" add constraint "feature_flags_org_id_fkey" FOREIGN KEY (org_id) REFERENCES organization(id) ON DELETE CASCADE not valid;

alter table "public"."feature_flags" validate constraint "feature_flags_org_id_fkey";

alter table "public"."webhook_subscriptions" add constraint "webhook_subscriptions_webhook_id_fkey" FOREIGN KEY (webhook_id) REFERENCES webhooks(id) not valid;

alter table "public"."webhook_subscriptions" validate constraint "webhook_subscriptions_webhook_id_fkey";

alter table "public"."webhooks" add constraint "webhooks_org_id_fkey" FOREIGN KEY (org_id) REFERENCES organization(id) ON DELETE CASCADE not valid;

alter table "public"."webhooks" validate constraint "webhooks_org_id_fkey";

create policy "Enable delete for authenticated users only"
on "public"."webhook_subscriptions"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT webhooks.id,
    webhooks.created_at,
    webhooks.is_verified,
    webhooks.org_id,
    webhooks.txt_record
   FROM webhooks
  WHERE (webhooks.id = webhook_subscriptions.webhook_id))));


create policy "Enable insert for authenticated users only"
on "public"."webhook_subscriptions"
as permissive
for insert
to authenticated
with check ((EXISTS ( SELECT webhooks.id,
    webhooks.created_at,
    webhooks.is_verified,
    webhooks.org_id,
    webhooks.txt_record
   FROM webhooks
  WHERE (webhooks.id = webhook_subscriptions.webhook_id))));


create policy "Enable select for authenticated users only"
on "public"."webhook_subscriptions"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT webhooks.id,
    webhooks.created_at,
    webhooks.is_verified,
    webhooks.org_id,
    webhooks.txt_record
   FROM webhooks
  WHERE (webhooks.id = webhook_subscriptions.webhook_id))));


create policy "Enable delete for authenticated users only"
on "public"."webhooks"
as permissive
for delete
to authenticated
using ((EXISTS ( SELECT organization.id,
    organization.created_at,
    organization.name,
    organization.owner,
    organization.is_personal,
    organization.soft_delete,
    organization.color,
    organization.icon,
    organization.has_onboarded
   FROM organization
  WHERE (organization.id = webhooks.org_id))));


create policy "Enable select for authenticated users only"
on "public"."webhooks"
as permissive
for select
to authenticated
using ((EXISTS ( SELECT organization.id,
    organization.created_at,
    organization.name,
    organization.owner,
    organization.is_personal,
    organization.soft_delete,
    organization.color,
    organization.icon,
    organization.has_onboarded
   FROM organization
  WHERE (organization.id = webhooks.org_id))));


