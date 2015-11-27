# Copyright (c) 2015 Huawei Technologies India Pvt Ltd
# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import requests

from oslo.config import cfg
from neutron.openstack.common import log as logging
from neutron.openstack.common import jsonutils
from neutron.plugins.common import constants
from neutron.common import constants as n_const
from neutron.extensions import portbindings
from neutron.plugins.ml2 import driver_api as api

LOG = logging.getLogger(__name__)

ONOS_DRIVER_OPTS = [
    cfg.StrOpt('url_path',
               default='',
               help=_('ONOS ReST interface URL')),
    cfg.StrOpt('username',
               default='',
               help=_('Username for authentication.')),
    cfg.StrOpt('password',
               default='',
               secret=True,  # do not expose value in the logs
               help=_('Password for authentication.'))
]

cfg.CONF.register_opts(ONOS_DRIVER_OPTS, "ml2_onos")


def send_msg(onos_path, onos_auth, msg_type, entity_path, entity=None):
    """Send message to the ONOS controller."""

    body = jsonutils.dumps(entity, indent=2) if entity else None
    path = '/'.join([onos_path, entity_path])
    LOG.debug("Sending MSG (%(msg)s) URL (%(path)s) JSON (%(entity)s)",
              {'msg': msg_type, 'path': path, 'entity': body})

    hdr = {'Content-Type': 'application/json'}
    req = requests.request(method=msg_type, url=path,
                           headers=hdr, data=body,
                           auth=onos_auth)
    req.raise_for_status()


class ONOSMechanismDriver(api.MechanismDriver):

    """Open Networking Operating System ML2 Driver for Neutron.

    Code which makes communication between ONOS and OpenStack Neutron
    possible.
    """
    def __init__(self):
        conf = cfg.CONF.ml2_onos
        self.onos_path = conf.url_path
        self.onos_auth = (conf.username, conf.password)
        self.vif_type = portbindings.VIF_TYPE_OVS
        self.vif_details = {portbindings.CAP_PORT_FILTER: True}

    def initialize(self):
        # No action required as of now. Can be extended in
        # the future if required.
        pass

    #@log_helpers.log_method_call
    def create_network_postcommit(self, context):
        entity_path = 'networks/' 
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'post',
                 entity_path, {'network': resource})

    #@log_helpers.log_method_call
    def update_network_postcommit(self, context):
        entity_path = 'networks/' + context.current['id']
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'put',
                 entity_path, {'network': resource})

    #@log_helpers.log_method_call
    def delete_network_postcommit(self, context):
        entity_path = 'networks/' + context.current['id']
        send_msg(self.onos_path, self.onos_auth, 'delete',
                 entity_path)

    #@log_helpers.log_method_call
    def create_subnet_postcommit(self, context):
        entity_path = 'subnets/' 
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'post',
                 entity_path, {'subnet': resource})

    #@log_helpers.log_method_call
    def update_subnet_postcommit(self, context):
        entity_path = 'subnets/' + context.current['id']
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'put',
                 entity_path, {'subnet': resource})

    #@log_helpers.log_method_call
    def delete_subnet_postcommit(self, context):
        entity_path = 'subnets/' + context.current['id']
        send_msg(self.onos_path, self.onos_auth, 'delete',
                 entity_path)

    #@log_helpers.log_method_call
    def create_port_postcommit(self, context):
        entity_path = 'ports/'
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'post',
                 entity_path, {'port': resource})

    #@log_helpers.log_method_call
    def update_port_postcommit(self, context):
        entity_path = 'ports/' + context.current['id']
        resource = context.current.copy()
        send_msg(self.onos_path, self.onos_auth, 'put',
                 entity_path, {'port': resource})

    #@log_helpers.log_method_call
	
    def delete_port_postcommit(self, context):
        entity_path = 'ports/' + context.current['id']
        send_msg(self.onos_path, self.onos_auth, 'delete',
                 entity_path)
    def bind_port(self, context):
        LOG.debug("Attempting to bind port %(port)s on "
                  "network %(network)s",
                  {'port': context.current['id'],
                   'network': context.network.current['id']})
        for segment in context.network.network_segments:
            if self.check_segment(segment):
                context.set_binding(segment[api.ID],
                                    self.vif_type,
                                    self.vif_details,
                                    status=n_const.PORT_STATUS_ACTIVE)
                LOG.debug("Bound using segment: %s", segment)
                return
            else:
                LOG.debug("Refusing to bind port for segment ID %(id)s, "
                          "segment %(seg)s, phys net %(physnet)s, and "
                          "network type %(nettype)s",
                          {'id': segment[api.ID],
                           'seg': segment[api.SEGMENTATION_ID],
                           'physnet': segment[api.PHYSICAL_NETWORK],
                           'nettype': segment[api.NETWORK_TYPE]})
    def check_segment(self, segment):
        """Verify a segment is valid for the ONOS MechanismDriver.

        Verify the requested segment is supported by ONOS and return True or
        False to indicate this to callers.
        """
        network_type = segment[api.NETWORK_TYPE]
        return network_type in [constants.TYPE_LOCAL, constants.TYPE_GRE,
                                constants.TYPE_VXLAN, constants.TYPE_VLAN]
