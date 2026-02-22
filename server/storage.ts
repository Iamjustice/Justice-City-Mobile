import { type User, type InsertUser } from "@shared/schema";
import { randomUUID } from "crypto";
import { createClient, type SupabaseClient } from "@supabase/supabase-js";

const USERS_TABLE = process.env.SUPABASE_USERS_TABLE || "users";

// modify the interface with any CRUD methods
// you might need

export interface IStorage {
  getUser(id: string): Promise<User | undefined>;
  getUserByUsername(username: string): Promise<User | undefined>;
  createUser(user: InsertUser): Promise<User>;
}

class SupabaseStorage implements IStorage {
  constructor(private readonly client: SupabaseClient) {}

  async getUser(id: string): Promise<User | undefined> {
    const { data, error } = await this.client
      .from(USERS_TABLE)
      .select("id, username, password")
      .eq("id", id)
      .maybeSingle<User>();

    if (error) throw new Error(`Supabase getUser failed: ${error.message}`);
    return data ?? undefined;
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    const { data, error } = await this.client
      .from(USERS_TABLE)
      .select("id, username, password")
      .eq("username", username)
      .maybeSingle<User>();

    if (error) {
      throw new Error(`Supabase getUserByUsername failed: ${error.message}`);
    }

    return data ?? undefined;
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const payload = { ...insertUser, id: randomUUID() };

    const { data, error } = await this.client
      .from(USERS_TABLE)
      .insert(payload)
      .select("id, username, password")
      .single<User>();

    if (error || !data) {
      throw new Error(`Supabase createUser failed: ${error?.message ?? "No data returned"}`);
    }

    return data;
  }
}

class MemStorage implements IStorage {
  private users: Map<string, User>;

  constructor() {
    this.users = new Map();
  }

  async getUser(id: string): Promise<User | undefined> {
    return this.users.get(id);
  }

  async getUserByUsername(username: string): Promise<User | undefined> {
    return Array.from(this.users.values()).find(
      (user) => user.username === username,
    );
  }

  async createUser(insertUser: InsertUser): Promise<User> {
    const id = randomUUID();
    const user: User = { ...insertUser, id };
    this.users.set(id, user);
    return user;
  }
}

function createStorage(): IStorage {
  const url = process.env.SUPABASE_URL;
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (url && serviceRoleKey) {
    const client = createClient(url, serviceRoleKey, {
      auth: { persistSession: false, autoRefreshToken: false },
    });

    return new SupabaseStorage(client);
  }

  return new MemStorage();
}

export const storage = createStorage();
