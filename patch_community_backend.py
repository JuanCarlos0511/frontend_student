import re

# 1. Update Routes
with open('../backend/src/routes/community.routes.js', 'r') as f:
    routes = f.read()

if "getMembers" not in routes:
    routes = routes.replace(
        "// GET /api/communities/:id — detalle de comunidad",
        "// GET /api/communities/:id/members — listar miembros\nrouter.get('/:id/members', CommunityController.getMembers);\n\n// GET /api/communities/:id — detalle de comunidad"
    )
    with open('../backend/src/routes/community.routes.js', 'w') as f:
        f.write(routes)


# 2. Update Controller
with open('../backend/src/controllers/community.controller.js', 'r') as f:
    ctrl = f.read()

if "getMembers" not in ctrl:
    ctrl_method = """
  /** GET /api/communities/:id/members */
  async getMembers(req, res, next) {
    try {
      const communityId = parseInt(req.params.id, 10);
      const members = await CommunityService.getMembers(communityId);
      return res.status(200).json({
        success: true,
        data: members,
      });
    } catch (error) {
      next(error);
    }
  },
"""
    # Insert before /** POST /api/communities/:id/join */
    pos = ctrl.find("/** POST /api/communities/:id/join */")
    ctrl = ctrl[:pos] + ctrl_method + "\n  " + ctrl[pos:]
    with open('../backend/src/controllers/community.controller.js', 'w') as f:
        f.write(ctrl)


# 3. Update Service
with open('../backend/src/services/community.service.js', 'r') as f:
    svc = f.read()

if "getMembers" not in svc:
    svc_method = """
  async getMembers(communityId) {
    const community = await CommunityModel.findById(communityId);
    if (!community) {
      const error = new Error('Comunidad no encontrada.');
      error.statusCode = 404;
      throw error;
    }
    return CommunityModel.findMembers(communityId);
  },
"""
    # Insert before async isMember
    pos = svc.find("async isMember")
    svc = svc[:pos] + svc_method + "\n  " + svc[pos:]
    with open('../backend/src/services/community.service.js', 'w') as f:
        f.write(svc)


# 4. Update Model
with open('../backend/src/models/community.model.js', 'r') as f:
    mod = f.read()

if "findMembers" not in mod:
    mod_method = """
  /**
   * Obtiene los miembros de la comunidad.
   */
  async findMembers(communityId) {
    const sql = `
      SELECT s.id, s.first_name, s.last_name, s.profile_photo_path
      FROM community_members cm
      JOIN students s ON s.id = cm.student_id
      WHERE cm.community_id = $1
      ORDER BY cm.joined_at ASC;
    `;
    const result = await query(sql, [communityId]);
    return result.rows;
  },
"""
    pos = mod.rfind("module.exports")
    mod = mod[:pos] + mod_method + "\n" + mod[pos:]
    with open('../backend/src/models/community.model.js', 'w') as f:
        f.write(mod)

print("Backend patched")
