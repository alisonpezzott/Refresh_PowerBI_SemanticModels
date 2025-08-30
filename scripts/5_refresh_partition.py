import pyfabricops as pf

pf.set_auth_provider('oauth') 
pf.setup_logging(format_style='minimal')  

pf.refresh_semantic_model(
    'WS_Demo',
    'Production',
    apply_refresh_policy=False,
    objects=[
        {
            'table': 'Production',
            'partition': '2025Q307'
        }
    ]
)
